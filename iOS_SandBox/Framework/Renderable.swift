//
//  Renderable.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 07/04/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

protocol AnyRenderable {
    func _render(with model: Any)
}

protocol Renderable: class, AnyRenderable {
    associatedtype Model: Equatable
    var current: VS<Model>? { set get }
    var pending: VS<Model>? { set get }
    func set(with model: VS<Model>?)
    func render()
    func _render()
}

extension Renderable {
    func set(with model: VS<Model>?) {
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
        guard let model = model as? VS<Model> else { return }
        self.set(with: model)
        self.render()
    }
}

typealias RenderableView = Renderable & UIView

protocol PlugguableViewProtocol: RenderableView {
    init()
}

func createInstance<T>(ofType: T.Type) -> T where T: PlugguableViewProtocol {
    return ofType.init()
}

class SectionView<Head, Body, Tail>: UIStackView & Renderable & PlugguableViewProtocol
    where Head: PlugguableViewProtocol, Body: PlugguableViewProtocol, Tail: PlugguableViewProtocol {
    typealias Model = SectionVM<Head.Model, Body.Model, Tail.Model>
    var current: VS<Model>?
    var pending: VS<Model>?
    var head: Head
    var body: Body
    var tail: Tail
    required init() {
        self.head = UINib.view() ?? createInstance(ofType: Head.self)
        self.body = UINib.view() ?? createInstance(ofType: Body.self)
        self.tail = UINib.view() ?? createInstance(ofType: Tail.self)
        super.init(frame: .zero)
    }
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

typealias HSectionView = SectionView
class VSectionView<Head, Body, Tail>: SectionView<Head, Body, Tail>
    where Head: PlugguableViewProtocol, Body: PlugguableViewProtocol, Tail: PlugguableViewProtocol  {
    required init() {
        super.init()
        self.axis = .vertical
    }
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension SectionView {
    func _render() {
        guard let pending = pending else { return }
        switch pending {
        case .show(let m):
            isHidden = false
            spacing = CGFloat(m.spacing.0)
            [head, body, tail].forEach { self.addArrangedSubview($0) }
            head.set(with: m.head)
            body.set(with: m.body)
            tail.set(with: m.tail)
            head.render()
            body.render()
            tail.render()
        default:
            isHidden = true
        }
    }
}

struct SectionVM<Head, Body, Tail>: Equatable where Head: Equatable, Body: Equatable, Tail: Equatable {
    static func == (lhs: SectionVM<Head, Body, Tail>, rhs: SectionVM<Head, Body, Tail>) -> Bool {
        return  lhs.head == rhs.head           &&
                lhs.body == rhs.body           &&
                lhs.tail == rhs.tail           &&
                lhs.spacing.0 == rhs.spacing.0 &&
                lhs.spacing.1 == rhs.spacing.1
    }
    let head: VS<Head>
    let body: VS<Body>
    let tail: VS<Tail>
    let spacing: (Double, Double)
    init(
        _ head: VS<Head>,
        _ body: VS<Body>,
        _ tail: VS<Tail>,
        spacing: (Double, Double) = (0.0, 0.0)
    ) {
        self.head = head
        self.body = body
        self.tail = tail
        self.spacing = spacing
    }
}
