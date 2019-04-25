//
//  Throttle.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 07/04/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation

protocol ThrottleObserver: class {
    func updated()
}

protocol Throttle: class {
    var observer: ThrottleObserver! { get }
    var isOpening: Bool { get set }
    func throttle(open: Bool)
    func push()
}
extension Throttle {
    func push() {
        if isOpening { observer?.updated() }
    }
    func throttle(open: Bool) {
        isOpening = open; push()
    }
}

protocol Resolvable: class {
    associatedtype At
    func resolve<T>(at: At) -> T?
}

class Resolver<EC, At>: Resolvable {
    let ec: EC
    init(ec: EC) {
        self.ec = ec
    }
    func resolve<T>(at: At) -> T? {
        return nil
    }
}
