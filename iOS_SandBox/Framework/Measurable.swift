//
//  Measurable.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 01/08/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

typealias RootView = MeasurableRoot<
    Padding<        // top: 10, left: 20
        Padding<    // bottom: 30, right: 40
            List
//            MainTest // width: 100, height: 100
        >
    >
>   // MeasureRoot 예상 결과 -> width: 160, height: 140
var cal = 0
func test11111() {
//    let main1: MainTest = UINib.view()!
//    let main2: MainTest = UINib.view()!
//    let main3: MainTest = UINib.view()!
//    let t = RootView()
//    t.top.constant = 10
//    t.left.constant = 20
//    t.content.bottom.constant = 30
//    t.content.right.constant  = 40
//    t.content.content.content.children = [
//        main1, main2, main3
//    ]
//    t.measureBox.update(
//        result: .caculated(CGSize(width: 400, height: 400)),
//        shadow: .caculated(CGSize(width: 400, height: 400))
//    )
//    t.measure()
//    print("-------------")
////    t.measureBox.shadow = .caculated(CGSize(width: 400, height: 400))
////    t.measureBox.result = .caculated(CGSize(width: 400, height: 400))
////    t.measure()
//    print("cal := \(cal)")
}

func createInstance<T>(ofType: T.Type) -> T where T: InitializableView & Measurable {
    return ofType.init()
}
enum MeasurableResult: Equatable {
    case notDetermined
    case caculated(CGSize)
}
protocol InitializableView: UIView { init() }
class MeasureBox {
    static func createInstance() -> MeasureBox { return MeasureBox() }
    weak var parent: Measurable!
    private var _result: MeasurableResult
    var result: MeasurableResult { return _result }
    private var _shadow: MeasurableResult
    var shadow: MeasurableResult { return _shadow }
    init(
        parent: Measurable! = nil,
        result: MeasurableResult = .notDetermined,
        shadow: MeasurableResult = .notDetermined
    ) {
        self.parent = parent
        self._result = result
        self._shadow = shadow
    }
    func update(result: MeasurableResult, shadow: MeasurableResult, measureAgain: Bool = true) {
        let needUpdate = self.result != result
        _result = result
        _shadow = shadow
        if needUpdate && measureAgain {
            guard let _ = self.parent else { return }
            self.parent.measure()
        }
    }

}
protocol Measurable: class {
    var measureBox: MeasureBox { get set }
    func measure()
}
protocol MeasurableNode: InitializableView & Measurable { }


class MeasurableRoot<Content>: Padding<Content>
    where Content: MeasurableNode {    // 부모가 존재하지 않으므로 본인이 스스로 bounds 변화를 감지해야 한다.
    var isSecondLoop = false
    required init() {
        super.init()
        measureBox.parent = MeasurableView.dummy
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func measure() {   // 부모에 의존하지 않는 연산을 해야 한다.
        cal += 1
        if measureBox.parent === MeasurableView.dummy {
            switch measureBox.result {
            case .notDetermined: break
            case .caculated(let pSize):
                var result: CGSize
                var shadow: CGSize
                content.measure()
                switch content.measureBox.result {
                case .notDetermined:
                    result = pSize
                    shadow = CGSize(
                        width: pSize.width - left.constant - right.constant,
                        height: pSize.height - top.constant - bottom.constant
                    )
                case .caculated(let cSize):
                    result = pSize
                    shadow = CGSize(width: cSize.width, height: cSize.height)

                }
                if result != shadow {   // 충돌!
                    // 어떻게 할지 정책으로 풀어야 한다.
//                    print("wrap_content")
                    result = CGSize(
                        width: shadow.width + left.constant + right.constant,
                        height: shadow.height + top.constant + bottom.constant
                    )
                }
                measureBox.update(
                    result: .caculated(result),
                    shadow: .caculated(shadow)
                )
            }
        }
    }
}

class Padding<Content>: MeasurableView
    where Content: MeasurableNode {
    var top:    NSLayoutConstraint!
    var left:   NSLayoutConstraint!
    var bottom: NSLayoutConstraint!
    var right:  NSLayoutConstraint!
//    var measureBox = MeasureBox.createInstance()
    var content: Content!
    required init() {
        super.init(frame: .zero)
        content = UINib.view() ?? createInstance(ofType: Content.self)
        content.measureBox.parent = self
        addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        top    = content.topAnchor.constraint(equalTo: topAnchor)
        left   = content.leftAnchor.constraint(equalTo: leftAnchor)
        bottom = bottomAnchor.constraint(equalTo: content.bottomAnchor)
        right  = rightAnchor.constraint(equalTo: content.rightAnchor)
        NSLayoutConstraint.activate([top, left, bottom, right])
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func measure() {
        cal += 1
        switch measureBox.parent.measureBox.shadow {
        case .notDetermined:
            measureBox.update(result: .notDetermined, shadow: .notDetermined)
        case .caculated(let pSize):
            var result: CGSize
            var shadow: CGSize
            // content가 사이즈를 계산하기 위한 힌트를 content의 measureBox의 shadow로 넘겨준다.
            content.measureBox.update(
                result: content.measureBox.result,
                shadow: .caculated(
                    CGSize(
                        width: pSize.width - left.constant - right.constant,
                        height: pSize.height - top.constant - bottom.constant
                    )
                ),
                measureAgain: false
            )
            content.measure()
            switch content.measureBox.result {
            case .notDetermined:
                result = pSize
                shadow = CGSize(
                    width: pSize.width - left.constant - right.constant,
                    height: pSize.height - top.constant - bottom.constant
                )
            case .caculated(let cSize):
                result = pSize
                shadow = CGSize(width: cSize.width, height: cSize.height)
            }
            if result != shadow {   // 충돌!
                // 어떻게 할지 정책으로 풀어야 한다.
//                    print("wrap_content")
                result = CGSize(
                    width: shadow.width + left.constant + right.constant,
                    height: shadow.height + top.constant + bottom.constant
                )
            }
            measureBox.update(
                result: .caculated(result),
                shadow: .caculated(shadow)
            )
        }
    }
}

class MeasurableView: UIView, MeasurableNode {
    static let dummy: MeasurableView = MeasurableView()
    var measureBox = MeasureBox.createInstance()
    func measure() {
        let hint = measureBox.shadow
        switch hint {
        case .notDetermined: break
        case .caculated(let hint):
            let size: CGSize
            switch (hint.width, hint.height) {
            case (CGFloat.greatestFiniteMagnitude, _):
                size = systemLayoutSizeFitting(
                    hint,
                    withHorizontalFittingPriority: .fittingSizeLevel,
                    verticalFittingPriority: .required
                )
            default:
                size = systemLayoutSizeFitting(
                    hint,
                    withHorizontalFittingPriority: .required,
                    verticalFittingPriority: .fittingSizeLevel
                )
            }
            measureBox.update(result: .caculated(size), shadow: .caculated(size), measureAgain: false)
        }
    }
}


class TestView: MeasurableView {
    required init() { super.init(frame: .zero) }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func measure() {
        cal += 1
        measureBox.update(
            result: .caculated(CGSize(width: 100, height: 100)),
            shadow: .caculated(CGSize(width: 100, height: 100)),
            measureAgain: false
        )
    }
}



class List: MeasurableView {
    static let identifierPLead     = "MeasurableNode.Child.Force.Lead"
    static let identifierPTrailing = "MeasurableNode.Child.Force.Trailing"
    static let identifierPTop      = "MeasurableNode.Child.Force.Top"
    static let identifierPBottom   = "MeasurableNode.Child.Force.Bottom"
    enum Direction { case vertical, horizontal }
    var children: [MeasurableNode] = [] {
        didSet {
            oldValue.forEach { $0.removeFromSuperview() }
            measure()
        }
    }
    var direction: Direction = .vertical
    var gap: CGFloat = 10
    override func measure() {
        let parentBox = measureBox.parent.measureBox
        switch parentBox.result {
        case .notDetermined:
            measureBox.update(result: .notDetermined, shadow: .notDetermined)
        case .caculated(let pSize):
            var height: CGFloat = 0
            subviews.forEach { view in
                view.constraints.forEach { [unowned view] (con) in
                    if con.identifier?.contains("MeasurableNode.Child.Force.") ?? false {
                        view.removeConstraint(con)
                    }
                }
                view.removeFromSuperview()
            }
            children.forEach { [unowned self] child in
                self.addSubview(child)
                child.measureBox.parent = self
                child.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    also(child.leadingAnchor.constraint(equalTo: self.leadingAnchor)) {
                        $0.identifier = List.identifierPLead
                    },
                    also(child.trailingAnchor.constraint(equalTo: self.trailingAnchor)) {
                        $0.identifier = List.identifierPTrailing
                    },
                    also(child.topAnchor.constraint(equalTo: self.topAnchor)) {
                        $0.identifier = List.identifierPTop
                        $0.constant = height
                    }
                ])
                if !child.isHidden {
                    // content가 사이즈를 계산하기 위한 힌트를 content의 measureBox의 shadow로 넘겨준다.
                    child.measureBox.update(
                        result: child.measureBox.result,
                        shadow: .caculated(
                            CGSize(
                                width: pSize.width - 0 - 0,
                                height: CGFloat.greatestFiniteMagnitude
                            )
                        ),
                        measureAgain: false
                    )
                    child.measure()
                    switch child.measureBox.result {
                    case .notDetermined: break
                    case .caculated(let cSize):
                        height += cSize.height
                        height += gap
                    }
                }
            }
            if let child = children.last {
                let bottom = child.bottomAnchor.constraint(equalTo: self.bottomAnchor)
                bottom.identifier = List.identifierPBottom
                bottom.isActive = true
                height -= bottom.constant
            }
            height -= gap
            height = max(height, 0)
            let result = CGSize(width: pSize.width, height: height)
            measureBox.update(
                result: .caculated(result),
                shadow: .caculated(result)
            )
        }
    }
}

class Section<Head, Body, Tail>: MeasurableView
    where Head: MeasurableNode, Body: MeasurableNode, Tail: MeasurableNode {
}
