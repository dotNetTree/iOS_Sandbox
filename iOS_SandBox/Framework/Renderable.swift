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
    var current: Model? { set get }
    var pending: Model? { set get }
    func set(with model: Model?)
    func render()
    func _render()
}

extension Renderable {
    func set(with model: Model?) {
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
        guard let model = model as? Model else { return }
        self.set(with: model)
        self.render()
    }
}

typealias RenderableView = Renderable & UIView

protocol PlugguableViewProtocol: Renderable & UIView {
    init()
}

func createInstance<T>(ofType: T.Type) -> T where T: PlugguableViewProtocol {
    return ofType.init()
}

class SectionView<Head, Body, Tail>: UIStackView & PlugguableViewProtocol
    where Head: PlugguableViewProtocol, Body: PlugguableViewProtocol, Tail: PlugguableViewProtocol {
    typealias Model = ViewState<SectionVM<Head.Model, Body.Model, Tail.Model>>
    var current: Model?
    var pending: Model?
    var head: Head
    var body: Body
    var tail: Tail
    fileprivate var wrappedBody: PaddingView<Body>
    required init() {
        self.wrappedBody = PaddingView<Body>()
        self.head = UINib.view() ?? createInstance(ofType: Head.self)
        self.body = wrappedBody.content
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
            [head, wrappedBody, tail].forEach { self.addArrangedSubview($0) }
            head.set(with: m.head)
            switch axis {
            case .horizontal:
                wrappedBody.set(with: PaddingVM(m.body, spacing: (0, m.spacing.0, 0, m.spacing.1)))
            case .vertical:
                wrappedBody.set(with: PaddingVM(m.body, spacing: (m.spacing.0, 0, m.spacing.1, 0)))
            @unknown default: break
            }
            tail.set(with: m.tail)
            head.render()
            wrappedBody.render()
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
    let head: Head
    let body: Body
    let tail: Tail
    let spacing: (Double, Double)
    init(
        _ head: Head,
        _ body: Body,
        _ tail: Tail,
        spacing: (Double, Double) = (0.0, 0.0)
    ) {
        self.head = head
        self.body = body
        self.tail = tail
        self.spacing = spacing
    }
}

class PaddingView<Content>: UIView & PlugguableViewProtocol
    where Content: PlugguableViewProtocol {
    typealias Model = PaddingVM<Content.Model>
    var current: Model?
    var pending: Model?
    var content: Content
    var top: NSLayoutConstraint!
    var left: NSLayoutConstraint!
    var bottom: NSLayoutConstraint!
    var right: NSLayoutConstraint!
    required init() {
        self.content = UINib.view() ?? createInstance(ofType: Content.self)
        super.init(frame: .zero)
        content.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(content)
        top    = content.topAnchor.constraint(equalTo: self.topAnchor)
        left   = content.leftAnchor.constraint(equalTo: self.leftAnchor)
        bottom = self.bottomAnchor.constraint(equalTo: content.bottomAnchor)
        right  = self.rightAnchor.constraint(equalTo: content.rightAnchor)
        NSLayoutConstraint.activate([top, left, bottom, right])
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension PaddingView {
    func _render() {
        guard let pending = pending else { return }
        let m       = pending.content
        let padding = pending.spacing
        top.constant    = CGFloat(padding.top)
        left.constant   = CGFloat(padding.left)
        bottom.constant = CGFloat(padding.bottom)
        right.constant  = CGFloat(padding.right)
        content.set(with: m)
        content.render()
        isHidden = (m as? ViewStateHiddenable)?.isHidden() ?? false
    }
}

struct PaddingVM<Content>: Equatable where Content: Equatable {
    static func == (lhs: PaddingVM<Content>, rhs: PaddingVM<Content>) -> Bool {
        return  lhs.content == rhs.content               &&
                lhs.spacing.top == lhs.spacing.top       &&
                lhs.spacing.left == lhs.spacing.left     &&
                lhs.spacing.bottom == lhs.spacing.bottom &&
                lhs.spacing.right == lhs.spacing.right
    }
    let content: Content
    let spacing: (top: Double, left: Double, bottom: Double, right: Double)
    init(
        _ content: Content,
        spacing: (top: Double, left: Double, bottom: Double, right: Double) = (0.0, 0.0, 0.0, 0.0)
    ) {
        self.content = content
        self.spacing = spacing
    }
}
