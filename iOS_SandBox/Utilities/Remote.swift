//
//  Remote.swift
//  iOS_SandBox
//
//  Created by Taehyeon Jake Lee on 02/05/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

protocol PayloadProtocol: Codable {
    func all() -> [String: Any]?
    func isValidated() -> Bool
}
extension PayloadProtocol {
    func all() -> [String: Any]? {
        guard
            let data  = try? JSONEncoder().encode(self),
            let dic = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: Any]
            else {
                return nil
        }
        return dic
    }
}

enum APIFail: Error {
    case offline(String)
    case timeout(String)
    case client(statusCode: Int, raw: Data?)
    case server(statusCode: Int, raw: Data?)
    case decode(desc: String)
    case unknown(statusCode: Int, raw: Data?)
}
extension APIFail {
    func analyze() -> ModelError {
        let business = { (statusCode: Int, raw: Data?) -> ModelError in
            var msg = "NETWORK_ERR"
            if let json = raw?.json() as? [String: Any] {
                msg = (json["displayMessage"] as? String)
                    ?? (json["message"] as? String)
                    ?? msg
                return .business(msg: msg, encoded: json, (statusCode, raw))
            } else {
                return .business(msg: msg, encoded: nil, (statusCode, raw))
            }
        }
        switch self {
        case let .offline(msg):             return .network(msg: msg)
        case let .timeout(msg):             return .network(msg: msg)
        case let .client(statusCode, raw):  return business(statusCode, raw)
        case let .server(statusCode, raw):  return business(statusCode, raw)
        case let .unknown(statusCode, raw): return business(statusCode, raw)
        case .decode(_):
            return .business(msg: "NETWORK_ERR", encoded: nil, (-9999, nil))
        }
    }
}
enum ModelError: Error {
    case network(msg: String)
    case business(msg: String, encoded: Any?, (statusCode: Int, raw: Data?))
}
extension ModelError: Equatable {
    static func == (lhs: ModelError, rhs: ModelError) -> Bool {
        switch (lhs, rhs) {
        case (.network(let lhsMsg), .network(let rhsMsg)):               return lhsMsg == rhsMsg
        case (.business(let lhsMsg, _, _), .business(let rhsMsg, _, _)): return lhsMsg == rhsMsg
        default: return false
        }
    }
}

protocol APIProtocol: class {
    associatedtype ResponseType: Codable
    var payload       : PayloadProtocol { get set }

    var urlString     : String          { get set }
    var method        : HTTPMethod      { get set }
    var delay         : TimeInterval    { get set }
    var retryCount    : Int             { get set }

    var repeatInterval: TimeInterval    { get set }
    var repeatCount   : Int             { get set }

    func request(completion: @escaping (Swift.Result<ResponseType?, APIFail>) -> Void)
    func cancel()
}
extension APIProtocol {
    typealias Completion<T> = (Swift.Result<T?, APIFail>) -> Void

    func changeCompletionType<T>(with completion: @escaping Completion<T>) -> (DataResponse<T?>) -> Void {
        var tsBy503: TimeInterval?
        return { (res) in
            let statusCode = res.response?.statusCode ?? 0
            switch res.result {
            case .success(let val):
                completion(.success((statusCode != 204 ? val : nil)))
            case .failure(let err):
                let errCode   = (err as NSError).code
                var fail: APIFail
                func decodingError(err: DecodingError) -> APIFail {
                    func key(_ context: DecodingError.Context) -> String {
                        let key = context.codingPath
                            .reduce("") { (accu, key) -> String in
                                let string = key.stringValue
                                if string.contains("Index") {
                                    let idx = string.split(separator: " ").last ?? ""
                                    return "\(accu)[\(idx)]"
                                }
                                return "\(accu)\(accu.count > 0 ? "." : "")\(string)"
                        }
                        return key
                    }
                    switch err {
                    case let .typeMismatch(type, context):
                        return .decode(desc: "[\(T.self)] type mismatch, type: \(type), key: \(key(context))")
                    case let .valueNotFound(type, context):
                        return .decode(desc: "[\(T.self)] value not found, type: \(type), key: \(key(context))")
                    case let .keyNotFound(_, context):
                        return .decode(desc: "[\(T.self)] key not found, key: \(key(context)), context: \(context)")
                    case let .dataCorrupted(context):
                        return .decode(desc: """
                            [\(T.self)] data corrupted, key: \(key(context)), context: \(context.debugDescription)
                            """)
                    @unknown default:
                        return .decode(desc: "unknown error")
                    }
                }
                switch (statusCode, errCode) {
                // 200 ok 의 body가 없는 경우
                case (200, _) where res.data == nil || res.data?.count == 0:
                    completion(.success(nil))
                    return
                // 200 ok 이나, result가 "FAILED"인 경우 ex) socialLogin
                case (200, 4865):
                    switch err {
                    case let err as DecodingError:
                        fail = decodingError(err: err)
                    default:
                        if let json = res.data?.json() as? [String: Any],
                            let result = json["result"] as? String,
                            result == "FAILED" {
                            fail = .client(statusCode: statusCode, raw: res.data)
                        } else {
                            fail = .unknown(statusCode: statusCode, raw: res.data)
                        }
                    }

                // 204 no Content의 body가 없는 경우
                case (204, _) :
                    completion(.success(nil))
                    return
                // client side timed out
                case (408, _) :
                    fail = .timeout("NETWORK_ERR")
                // client error
                case let (statusCode, _) where 400..<500 ~= statusCode:
                    fail = .client(statusCode: statusCode, raw: res.data)
                // server error
                case let (statusCode, _) where 500..<600 ~= statusCode:
                    if statusCode == 503 {
                        if let ts = tsBy503, Date.timeIntervalSinceReferenceDate - ts < 10 {
                            // 10초 내로 503 2번 얻어 맞으면 앱 종료.
                            // (이용자가 앱에서 계속 돌아다니면서 서버를 찌르는 행위를 원천적으로 막기 위함)
                            UIAlertController.showAlert(
                                title: "일시적인 장애 안내",
                                msg: "죄송합니다. 현재 서버 상태가 불안정하여 정상적인 이용이 어렵습니다. 잠시후 다시 접속해주세요.",
                                cancelButtonTitle: "앱 종료하기",
                                destructiveButtonTitle: nil,
                                otherButtonTitles: nil
                            ) { (_, _) in
                                exit(1)
                            }
                        } else {
                            tsBy503 = Date.timeIntervalSinceReferenceDate
                        }
                    }
                    fail = .server(statusCode: statusCode, raw: res.data)
                // client side timed out
                case (0, -1001):
                    fail = .timeout("NETWORK_ERR")
                // offline
                case (0, -1009):
                    fail = .offline("NETWORK_ERR")
                default:
                    switch err {
                    case let err as DecodingError:
                        fail = decodingError(err: err)
                    default:
                        fail = .unknown(statusCode: statusCode, raw: res.data)
                    }
                }
                completion(.failure(fail))
            }
        }
    }
}


let PayloadJSONEncoding = JSONEncoding.default

class APIBase<R>: APIProtocol where R: Codable {
    typealias ResponseType = R
    private let MULTI_PART_ERROR_CODE: Int = -562741

    var payload        : PayloadProtocol

    var urlString      : String       = ""
    var method         : HTTPMethod   = .get
    var delay          : TimeInterval = 0.0
    var retryCount     : Int          = 0

    var repeatInterval : TimeInterval = 0.0
    var repeatCount    : Int          = -1 // -1 은 무한 반복
    var formData       : ((inout MultipartFormData) -> Void)?
    var encoding       : ParameterEncoding?
    var headers        : HTTPHeaders?
    var timeoutInterval: (forRequest: TimeInterval?, forResource: TimeInterval?)
    var validations    : [DataRequest.Validation]?

    private var dataRequest: DataRequest?
    private var parameters: Parameters? { return self.payload.all() }

    #if DEBUG
    var mock: Any?
    #endif

    init(payload: PayloadProtocol) {
        self.payload = payload
    }

    func request(completion: @escaping (Swift.Result<ResponseType?, APIFail>) -> Void) {
        response(ResponseType.self, completion: changeCompletionType(with: completion))
        guard
            repeatCount != 0,
            repeatInterval > 0
            else { return }
        after(delay: repeatInterval) { [weak self] in
            guard let self = self else { return }
            if self.repeatCount > 0 { self.repeatCount -= 1 }
            self.request(completion: completion)
        }
    }
    func cancel() {
        dataRequest?.cancel()
    }

    private func response<T: Codable>(_ type: T.Type, completion: @escaping (DataResponse<T?>) -> Void) {
        let defaultConfig = APIConfiguration.default

        let timeoutIntervalForRequest  = self.timeoutInterval.forRequest  ?? defaultConfig.timeoutInterval.forRequest
        let timeoutIntervalForResource = self.timeoutInterval.forResource ?? defaultConfig.timeoutInterval.forResource

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest  = timeoutIntervalForRequest
        configuration.timeoutIntervalForResource = timeoutIntervalForResource

        let manager = Alamofire.SessionManager(configuration: configuration)

        switch self.formData {
        case _?:
            multipart(manager: manager, type: type) { dataResponse in
                _ = manager // !주의 - request가 끝날 때까지 [강한 참조]로 manager를 잡아둔다.
                completion(dataResponse)
            }
        default:
            normal(manager: manager, type: type) { dataResponse in
                _ = manager // !주의 - request가 끝날 때까지 [강한 참조]로 manager를 잡아둔다.
                completion(dataResponse)
            }
        }
    }

    private func filter<T: Codable>(
        type: T.Type,
        completion: @escaping (DataResponse<T?>) -> Void
        ) -> (DefaultDataResponse) -> Void {

        func dataResponse<T>(with res: DefaultDataResponse, result: @escaping () -> Result<T>) -> DataResponse<T> {
            return {  DataResponse<T>(request: res.request,
                                      response: res.response,
                                      data: res.data,
                                      result: result(),
                                      timeline: res.timeline) }()
        }

        let defaultConfig = APIConfiguration.default
        return { [weak self] (res) in
            guard let self = self else { return }
            #if DEBUG
            APIConfiguration.default.debug?(res, self.parameters)
            #endif
            guard res.error == nil else {
                switch (self.retryCount, res.response) {
                // 5xx 서버 에러 중, 503 서버 정검이 아니면서, retry가 있는 경우 재시도
                case let (retryCount, reponse?) where
                    retryCount > 0 && (500..<600 ~= reponse.statusCode) && 503 != reponse.statusCode:
                    self.retryCount -= 1
                    // 0.3초 후 다시 시도
                    after(delay: 0.3) { [weak self] in
                        guard let self = self else { return }
                        self.response(type, completion: completion)
                    }
                default:
                    completion(
                        dataResponse(with: res) { Result.init { throw res.error! } }
                    )
                }
                return
            }

            // multi-part의 경우 validate가 동작하지 않아 이쪽에서 걸러줘야 한다.
            guard 200..<300 ~= (res.response?.statusCode ?? self.MULTI_PART_ERROR_CODE) else {
                completion(
                    DataResponse.init(
                        request: res.request,
                        response: res.response,
                        data: res.data,
                        result: Result.failure(
                            NSError.init(
                                domain: "Multipart.Error",
                                code: self.MULTI_PART_ERROR_CODE,
                                userInfo: nil
                            )
                        )
                    )
                )
                return
            }

            // suspension 기능.
            // delay가 0이 나왔다는 것은 응답을 받는데 걸린 시간이 설정된 suspend값보다 크다(느렸다)는 것을 의미한다.
            let delay = max(0, (defaultConfig.suspend ?? 0) - res.timeline.latency)
            after(delay: delay) { [res] in
                completion(
                    dataResponse(with: res) {
                        Result.init {
                            let decoded: T?
                            do {
                                decoded = try JSONDecoder().decode(T.self, from: res.data!)
                            } catch let error {
                                ChPrint("============== DecodingError Error ==============")
                                func key(_ context: DecodingError.Context) -> String {
                                    let key = context.codingPath
                                        .reduce("") { (accu, key) -> String in
                                            let string = key.stringValue
                                            if string.contains("Index") {
                                                let idx = string.split(separator: " ").last ?? ""
                                                return "\(accu)[\(idx)]"
                                            }
                                            return "\(accu)\(accu.count > 0 ? "." : "")\(string)"
                                    }
                                    return key
                                }
                                switch error {
                                case let err as DecodingError:
                                    switch err {
                                    case let .typeMismatch(type, context):
                                        ChPrint("typeMismatch")
                                        ChPrint("type := [\(type)]")
                                        ChPrint("key := \(key(context))")
                                    case let .valueNotFound(type, context):
                                        ChPrint("valueNotFound")
                                        ChPrint("type := [\(type)]")
                                        ChPrint("key := \(key(context))")
                                    case let .keyNotFound(_, context):
                                        ChPrint("keyNotFound")
                                        ChPrint("key := [\(key(context))]")
                                        ChPrint("\(context)")
                                    case let .dataCorrupted(context):
                                        ChPrint("dataCorrupted at := \(key(context))")
                                        ChPrint(context.debugDescription)
                                    @unknown default:
                                        ChPrint("unknown error")
                                    }
                                default: break
                                }
                                ChPrint("=================================================")
                                throw error
                            }
                            return decoded
                        }
                    }
                )
            }
        }
    }

    private func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: "\(key)[]", value: value)
            }
        } else if let value = value as? NSNumber {
            components.append(
                (key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!, "\(value)")
            )
        } else if let bool = value as? Bool {
            components.append(
                (key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!, bool ? "1" : "0")
            )
        } else {
            components.append(
                (key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!, "\(value)")
            )
        }
        return components
    }

    private func multipart<T: Codable>(
        manager: SessionManager,
        type: T.Type,
        completion: @escaping (DataResponse<T?>) -> Void
        ) {
        let defaultConfig = APIConfiguration.default
        let headers = [:].extend(defaultConfig.headers).extend(self.headers)
        manager.upload(
            multipartFormData: { (multipartFormData) in
                var formData = multipartFormData
                self.parameters?
                    .keys
                    .sorted(by: <)
                    .reduce([(String, String)]()) {
                        $0 + self.queryComponents(fromKey: $1, value: (self.parameters?[$1])!)
                    }
                    .forEach {
                        if let data = $0.1.data(using: .utf8) {
                            formData.append(data, withName: $0.0)
                        }
                }
                self.formData?(&formData)
        },
            to: self.urlString,
            method: self.method,
            headers: headers,
            encodingCompletion: { [weak self] encodingResult in
                guard let self = self else { return }
                switch encodingResult {
                case .success(let upload, _, _):
                    self.dataRequest = upload
                    upload.response(completionHandler: self.filter(type: type, completion: completion))
                case .failure(let encodingError):
                    completion(
                        DataResponse.init(
                            request: nil,
                            response: nil,
                            data: nil,
                            result: Result.failure(encodingError)
                        )
                    )
                }
            }
        )
    }

    private func normal<T: Codable>(
        manager: SessionManager,
        type: T.Type,
        completion: @escaping (DataResponse<T?>) -> Void
        ) {
        let defaultConfig = APIConfiguration.default
        let parameters    = self.parameters
        let encoding      = self.encoding ?? defaultConfig.encoding
        let headers       = [:].extend(defaultConfig.headers).extend(self.headers)
        if let array = parameters?["!ARRAY"] as? [Any],
            var request = try? URLRequest.init(url: self.urlString, method: self.method, headers: headers),
            let httpBody = try? JSONSerialization.data(withJSONObject: array) {
            request.httpBody = httpBody
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            self.dataRequest = manager.request(request)
        } else if let contentType = parameters?["!Content-Type"] as? String,        // contentType 지정이 필요한 경우 사용
            let param = parameters?["!PARAM"] as? [String: Any],
            var request = try? URLRequest.init(url: self.urlString, method: self.method, headers: headers),
            let httpBody = try? JSONSerialization.data(withJSONObject: param) {
            request.httpBody = httpBody
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
            self.dataRequest = manager.request(request)
        } else {
            self.dataRequest = manager.request(
                self.urlString,
                method: self.method,
                parameters: parameters,
                encoding: encoding,
                headers: headers)
        }
        guard let req = self.dataRequest else { return }
        self.validations?.forEach { req.validate($0) }

        after(delay: self.delay) { [weak self] in
            guard let self = self else { return }
            #if DEBUG
            guard self.mock == nil else {
                let data   = try? JSONSerialization.data(withJSONObject: self.mock!, options: .init(rawValue: 0))
                let result = Result.init { try JSONDecoder().decode(T.self, from: data!) }
                if let result = result as? Result<T?> {
                    completion(DataResponse<T?>(request: nil, response: nil, data: data, result: result))
                }
                return
            }
            #endif
            req.validate(statusCode: 200..<300)
                .response(completionHandler: self.filter(type: type, completion: completion))
        }
    }
    #if DEBUG
    @discardableResult
    func mock(_ by: Any?) -> Self {
        self.mock = by
        return self
    }
    #endif
}

struct APIConfiguration {
    private(set) var isFreezed: Bool
    private(set) var headers: HTTPHeaders?
    private(set) var encoding: ParameterEncoding
    private(set) var timeoutInterval: (forRequest: TimeInterval, forResource: TimeInterval) = (10, 10)
    private(set) var debug: ((DefaultDataResponse, Parameters?) -> Void)?
    private(set) var suspend: TimeInterval?

    static var `default`: APIConfiguration {
        return configulation
    }

    static func freeze(
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        timeoutInterval: (forRequest: TimeInterval, forResource: TimeInterval) = (10, 10),
        debug: ((DefaultDataResponse, Parameters?) -> Void)? = nil,
        suspend: TimeInterval? = 0.3
        ) {
        guard !configulation.isFreezed else { return }
        configulation = APIConfiguration(headers,
                                         encoding,
                                         timeoutInterval,
                                         debug,
                                         suspend)
        configulation.isFreezed = true
    }

    init(_ headers: HTTPHeaders?,
         _ encoding: ParameterEncoding,
         _ timeoutInterval: (forRequest: TimeInterval, forResource: TimeInterval),
         _ debug: ((DefaultDataResponse, Parameters?) -> Void)?,
         _ suspend: TimeInterval?) {
        self.headers = headers
        self.encoding = URLEncoding.default
        self.timeoutInterval = timeoutInterval
        self.debug = debug
        self.suspend = suspend
        self.isFreezed = false
    }
}
private var configulation: APIConfiguration = {
    return APIConfiguration(nil, URLEncoding.default, (10, 10), nil, nil)
}()

final class Sender<A, C>: Disposable where A: APIBase<C>, C: Codable {

    enum Error: Swift.Error {
        case validation
        case response(_ apiError: APIFail)
    }

    let api: A
    var isRight: Bool {
        guard let result = result else { return false }
        switch result {
        case .success: return true
        case .failure: return false
        }
    }
    private var _catch: ((Error) -> Void)?
    private var _done: ((C?) -> Void)?
    private var _finalize: (() -> Void)?

    private var result: Swift.Result<C?, Error>? {
        didSet {
            guard let result = result else { return }
            defer { _finalize?() }
            switch result {
            case .success(let val) : _done?(val)
            case .failure(let err) : _catch?(err)
            }
        }
    }

    func dispose() {
        cancel()
    }

    init(api: A) {
        self.api = api
        self.api.payload.isValidated() ? sendApi() : catchIsNotValidated()
    }
    private func sendApi() {
        self.api.request { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let err): self.result = .failure(.response(err))
            case .success(let val): self.result = .success(val)
            }
        }
    }
    private func catchIsNotValidated() {
        after { [weak self] in
            guard let self = self else { return }
            self.result = .failure(.validation)
        }
    }

    @discardableResult
    func `catch`(cb: @escaping (Error) -> Void) -> Self {
        _catch = cb
        guard let result = result else { return self }
        switch result {
        case .failure(let err):
            _catch?(err)
            after { [weak self] in
                guard let self = self else { return }
                self._finalize?()
            }
        case .success: break
        }
        return self
    }

    @discardableResult
    func done(cb: @escaping (C?) -> Void) -> Self {
        _done = cb
        guard let result = result else { return self }
        switch result {
        case .success(let val):
            _done?(val)
            after { [weak self] in
                guard let self = self else { return }
                self._finalize?()
            }
        case .failure: break
        }
        return self
    }

    @discardableResult
    func finalize(cb: @escaping () -> Void) -> Self {
        _finalize = cb
        return self
    }

    @discardableResult
    func disposed(by bag: DisposeBag) -> Self {
        bag.insert(self)
        return self
    }

    func cancel() {
        api.cancel()
    }

}

func SenderFactory<A, C>(context: Throttle & DisposeBase, api: A) -> Sender<A, C> where A: APIBase<C> {
    return Sender(api: api)
        .finalize { [weak context] in context?.push() }
        .disposed(by: context.disposeBag)
}
