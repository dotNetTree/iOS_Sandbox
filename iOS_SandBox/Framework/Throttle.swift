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
