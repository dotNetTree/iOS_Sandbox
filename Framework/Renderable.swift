//
//  Renderable.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 07/04/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation

protocol AnyRenderable {
    func _render(with model: Any)
}

protocol Renderable: class, AnyRenderable {
    associatedtype VM: Equatable
    var current: ViewState<VM>? { set get }
    var pending: ViewState<VM>? { set get }
    func set(with model: ViewState<VM>?)
    func render()
    func _render()
}

extension Renderable {
    func set(with model: ViewState<VM>?) {
        pending = model
    }
    func render() {
        guard let pending = pending else { return }
        if let current = current, current == pending { return }
        _render()
        self.pending = nil
        self.current = pending
    }
    func _render() {
        print("[Abstract] \(self) render를 구현해주세요!")
    }
    func _render(with model: Any) {
        guard let model = model as? ViewState<VM> else { return }
        self.set(with: model)
        self.render()
    }
}

