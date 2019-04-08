//
//  UIButton+Extension.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 08/04/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

typealias UIButtonTargetClosure = (UIButton) -> Void

class ClosureWrapper: NSObject {
    let closure: UIButtonTargetClosure
    init(_ closure: @escaping UIButtonTargetClosure) {
        self.closure = closure
    }
}

/////// Button Action 처리
extension UIButton {
    private struct AssociatedKeys {
        static var targetClosure    = "targetClosure"
        static var touchUpInside    = "touchUpInsideAction"
        static var touchUpOutside   = "touchUpOutsideAction"
        static var puddingEnable    = "puddingEnable"
    }
    // swiftlint:disable line_length
    private var targetClosure: UIButtonTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? ClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, ClosureWrapper(newValue),
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var touchUpInside: UIButtonTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.touchUpInside) as? ClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.touchUpInside, ClosureWrapper(newValue),
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var touchUpOutside: UIButtonTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.touchUpOutside) as? ClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.touchUpOutside, ClosureWrapper(newValue),
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @objc func touchDownAction() {
        guard let touchUpInside = touchUpInside else { return }
        touchUpInside(self)
    }

    @objc func touchUpInsideAction() {
        guard let targetClosure = self.targetClosure else { return }
        targetClosure(self)
    }

    @objc func touchUpOutsideAction() {
        guard let touchUpOutside = touchUpOutside else { return }
        touchUpOutside(self)
    }

}

extension UIButton {
    func addAction(_ event: UIControl.Event = .touchUpInside, closure: @escaping UIButtonTargetClosure) {
        switch event {
        case .touchDown:
            self.touchUpInside = closure
            addTarget(self, action: #selector(UIButton.touchDownAction), for: event)
        case .touchUpOutside:
            self.touchUpOutside = closure
            addTarget(self, action: #selector(UIButton.touchUpOutsideAction), for: event)
        default:
            self.targetClosure = closure
            addTarget(self, action: #selector(UIButton.touchUpInsideAction), for: event)
        }

    }
}
