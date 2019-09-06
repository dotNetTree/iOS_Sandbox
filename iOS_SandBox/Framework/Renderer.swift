//
//  Renderer.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 01/09/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

class _NoPlacer: Renderer.Placer {
    override func setPosition<T>(_ w: Double, _ h: Double, _ children: [Renderer.Item<T>]) -> Renderer.Rect {
        return Renderer.Rect.new(["w": w, "h": h])
    }
}
let NoPlacer = _NoPlacer()

class _InlinePlacer: Renderer.Placer {
    override func setPosition<T>(_ w: Double, _ h: Double, _ children: [Renderer.Item<T>]) -> Renderer.Rect {

        var x: Double = 0
        var y: Double = 0
        var lineHeight: Double = 0
        var prevWidth:  Double = 0
        children.forEach { (child) in
            child.reflow()
            let cw = child.offset.w
            let ch = child.offset.h
            x += prevWidth
            prevWidth = cw
            if w >= 0 && x + cw > w {
                x = 0
                y += lineHeight
                lineHeight = ch
            } else if lineHeight < ch {
                lineHeight = ch
            }
            child.offset = child.offset.new([ "x": x, "y": y ])
        }
        return Renderer.Rect.new([
            "w": w < 0 ? x + prevWidth : w,
            "h": h < 0 ? y + lineHeight : h
        ])
    }
}

let InlinePlacer = _InlinePlacer()

class ViewRenderer: Renderer.Renderer<UIView> {
    override init(target: UIView) {
        super.init(target: target)
        target.frame = CGRect.init(x: 0, y: 0, width: 1, height: 1)
    }
    override func addItem(_ renderer: Renderer.Renderer<UIView>) throws {
        target.addSubview(renderer.target)
    }
    override func removeItem(_ renderer: Renderer.Renderer<UIView>) throws {
        target.subviews.forEach {
            if $0 === renderer.target { $0.removeFromSuperview() }
        }
    }
    override func render(item: Renderer.Item<UIView>) throws {
        let view = target
        let children = item.children
        let x = item.offset.x
        let y = item.offset.y
        let w = item.offset.w
        let h = item.offset.h
        view.frame = CGRect(x: x, y: y, width: w, height: h)
        if let hex = item.style.backgroundColor.value as? String {
            view.backgroundColor = UIColor(hexString: hex)
        }
        children.forEach { $0.render() }
    }
}

typealias RendererRect = Renderer.Rect

enum Renderer {

    class Renderer<T> {
        var target: T
        init(target: T) {
            self.target = target
        }
        func render(item: Item<T>) throws -> Void {
            throw NSError(
                domain: "NotImplementedException",
                code: -1,
                userInfo: ["msg": "not implemented `render(item:)` function"]
            )
        }
        func addItem(_ renderer: Renderer<T>) throws -> Void {
            throw NSError(
                domain: "NotImplementedException",
                code: -1,
                userInfo: ["msg": "not implemented `addItem(renderer:)` function"]
            )
        }
        func removeItem(_ renderer: Renderer<T>) throws -> Void {
            throw NSError(
                domain: "NotImplementedException",
                code: -1,
                userInfo: ["msg": "not implemented `removeItem(renderer:)` function"]
            )
        }
    }

    class Rect: Equatable {
        static func == (lhs: RendererRect, rhs: RendererRect) -> Bool {
            return lhs.equals(rhs)
        }
        static func new(_ arg: [String: Double], base: Rect = Rect.base) -> Rect {
            return Rect(
                x: arg["x"] ?? base.x,
                y: arg["y"] ?? base.y,
                w: arg["w"] ?? base.w,
                h: arg["h"] ?? base.h
            )
        }
        static let base = Rect(x: 0, y: 0, w: 0, h: 0)
        let x: Double; let y: Double; let w: Double; let h: Double
        init(x: Double, y: Double, w: Double, h: Double) {
            self.x = x
            self.y = y
            self.w = w
            self.h = h
        }
        func new(_ opt: [String: Double]) -> Rect {
            return Rect.new(opt, base: self)
        }
        func newSize(_ rect: Rect) -> Rect {
            return Rect.new(["w": rect.w, "h": rect.h], base: self)
        }
        func newPos(_ rect: Rect) -> Rect {
            return Rect.new(["x": rect.x, "y": rect.y], base: self)
        }
        func equals(_ rect: Rect) -> Bool {
            return self.equalSize(rect) && self.equalPos(rect)
        }
        func equalSize(_ rect: Rect) -> Bool {
            return rect.w == self.w && rect.h == self.h
        }
        func equalPos(_ rect: Rect) -> Bool {
            return rect.x == self.x && rect.y == self.y
        }
    }

    class Placer {
        func setPosition<T>(_ w: Double, _ h: Double, _ children: [Item<T>]) -> Rect {
            return Rect.base
        }
    }
    class Style {
        var isUpdated: Bool = true
        private(set) var x: Length<Double>!
        private(set) var y: Length<Double>!
        private(set) var width: Length<Double>!
        private(set) var height: Length<Double>!
        private(set) var backgroundColor: Color!
        var placer: Placer = NoPlacer
        init() {
            x = Length<Double>(v: 0, style: self)
            y = Length<Double>(v: 0, style: self)
            width  = Length<Double>(v: 0, style: self)
            height = Length<Double>(v: 0, style: self)
            backgroundColor = Color.init(v: nil, style: self)
        }
        func setSize<T>(_ rect: Rect, _ style: Style, _ children: [Item<T>]) -> Rect {
            let w = try! style.width.get(rect.w)
            let h = try! style.height.get(rect.h)
            switch true {
            case _ where w >= 0 && h >= 0:    return Rect.new(["w": w, "h": h])
            case _ where children.count == 0: return Rect.new(["w": w < 0 ? 0 : w, "h": h < 0 ? 0 : h])
            default: return placer.setPosition(w, h, children);
            }
        }
    }

    class Color: Unit<String> {
        init(v: String?, style: Style?) {
            super.init(style: style)
            self.value = v
        }
        override func get(_ _container: String) throws -> Double {
            return 0
        }
    }

    class Length<T>: Unit<T> {
        init(v: T, style: Style?) {
            super.init(style: style)
            self.value = v
        }
        override func get(_ _container: T) throws -> Double {
            guard let container = _container as? Double else {
                throw NSError(
                    domain: "invalid type",
                    code: -1,
                    userInfo: ["msg": "invalid container: + \(_container as? String)"]
                )
            }
            let v = self.value
            switch v {
            case let v as String where v == "auto":
                return -1
            case let v as String where String(v.suffix(1)) == "%":
                return container * (Double(String(v.dropLast())) ?? 0) / 100
            case let v as Double:
                return v
            default: return 0
            }
        }
    }

    class Unit<T> {
        enum Union { // Union
            case string(String)
            case double(Double)
        }
        var style: Style?
        private var _value: Union? { didSet { style?.isUpdated = true } }
        var value: Any? {
            set {
                switch newValue {
                case let v as String: _value = Union.string(v)
                case let v as Int:    _value = Union.double(Double(v))
                case let v as Double: _value = Union.double(v)
                default: break
                }
            }
            get {
                switch _value {
                case .string(let v)?: return v
                case .double(let v)?: return v
                default:              return nil
                }
            }
        }
        init(style: Style?) {
            self.style = style
        }
        func get(_ _container: T) throws -> Double {
            throw NSError(
                domain: "NotImplementedException",
                code: -1,
                userInfo: ["msg": "not implemented `get()` function"]
            )
        }
    }

    class Item<T> {
        public var offset = Rect.base
        private(set) var style: Style = Style()
        private let renderer: Renderer<T>
        private(set) var children = [Item<T>]()
        private var container: Item<T>! = nil
        init(renderer: Renderer<T>) {
            self.renderer  = renderer
            self.container = self   // retain cycle !!!
        }
        func target() -> T {
            return renderer.target
        }
        func reflow() {
            if !style.isUpdated { container.render() }
            else {
                let size    = style.setSize(container.offset, style, children)
                let isEqaul = offset == size
                offset = offset.newSize(size)
                style.isUpdated = false
                if isEqaul || container === self { container.render() }
                else {
                    container.style.isUpdated = true
                    container.reflow()
                }
            }
        }
        func render() {
            do {
                try renderer.render(item: self)
            } catch {
                print(error)
            }
        }
        func addItem(item: Item<T>) {
            children.append(item)
            item.container = self
            try! renderer.addItem(item.renderer)
            style.isUpdated = true
            reflow()
        }
//        removeItem(item:Item<T>){
//        const children = this.children, i = children.indexOf(item);
//        if(i != -1){
//        children.splice(i, 1);
//        item.container = item;
//        this.renderer.removeItem(item.renderer);
//        this.style.isUpdated = true;
//        this.reflow();
//        }
//        }
    }
}
