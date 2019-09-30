//
//  Looper.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 09/07/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

/// Main Looper
let looper = also(Looper.Looper()) {
    $0.start()
}

fileprivate typealias Now = () -> Double
fileprivate let now: Now = { Date.timeIntervalSinceReferenceDate }

enum Looper {
    private class Updater {
        private var displayLink: CADisplayLink?
        private var activated = false
        fileprivate var loopers = [Looper]()
        func start() {
            if !activated {
                displayLink = CADisplayLink(target: self, selector: #selector(update))
                displayLink?.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
//                displayLink?.add(to: .main, forMode: .default)
            }
        }
        func stop() {
            displayLink?.invalidate()
            displayLink = nil
            activated = false
        }
        @objc func update() {
            loopers.forEach { $0.loop() }
        }
    }

    class Item {
        typealias Block = (Item) -> Void
        static let emptyBlock: Block = { _ in }
        var rate    = 0.0
        var current = 0.0
        var start   = 0.0
        var end     = 0.0
        var term    = 0.0
        var isTurn  = false
        var loop    = 1
        var isPaused   = false
//        var isInfinity = false

        var block: Block = Item.emptyBlock
        var ended: Block = Item.emptyBlock
        var next: Item?  = nil
        var isStop = false
        private var pauseStart = 0.0
        fileprivate var marked = false
    }

    class Pause {
        static let `default` = Pause()
        var active: Bool = false {
            didSet {
                let paused = active
                items.forEach { v in
                    (v as? Item)?.isPaused = paused
                }
            }
        }
        private var items = NSMutableSet()
        func add(item: Item) {
            item.isPaused = active
            items.add(item)
        }
        func remove(item: Item) {
            items.remove(item)
        }
    }
    
    class Looper {
        class ItemDSL {
            var time:  Double = -1
            var delay: Double = 0
            var loop:  Int = 1
            var block: Item.Block = Item.emptyBlock
            var ended: Item.Block = Item.emptyBlock
            var isInfinity: Bool  = false
        }

        private let concurrentQueue = DispatchQueue(
            label: "com.chela.lopper.lopper.queue",
            attributes: .concurrent
        )
        private var fps        = 0.0
        private var previus    = 0.0
        private var pauseStart = 0.0
        private var pausedTime = 0.0
        private var items    = NSMutableArray()
//        private var hasRemoveItems = false
//        private var add      = NSMutableArray()
        private var itemPool = NSMutableArray()

        private static let updater = Updater()

        private lazy var _sequence = Sequence(looper: self)
        private var sequence: Sequence {
            get { return _sequence }
        }

        func start() {
            Looper.updater.loopers += [self]
            Looper.updater.start()
        }

        fileprivate func loop() {
            guard pauseStart == 0.0 else { return }
            let c = now() - pausedTime
            let gap = c - previus
            if gap > 0.0 {
                fps = 1.0 / gap
            }
//            print(fps)
            previus = c
            guard items.count > 0 else { return }
            var _items: NSMutableArray!
            concurrentQueue.sync { _items = items }
            var hasRemoveItems = false
            let cnt = _items.count
            var i = 0
            while i < cnt {
                let item = _items[i] as! Item
                i += 1
                if item.isPaused || item.start > c {
                    continue
                }
                item.isTurn = false
                var isEnd = false
                item.rate = {
                    if item.end <= c {
                        item.loop -= 1
                        if item.loop == 0 {
                            isEnd = true
                            return 1.0
                        } else {
                            item.isTurn = true
                            item.start = c
                            item.end = c + item.term
                            return 0.0
                        }
                    } else if item.term == 0.0 {
                        return 0.0
                    } else {
                        return (c - item.start) / item.term
                    }
                }()
                item.current = c
                item.isStop = false
                item.block(item)
                if item.isStop || isEnd {
                    item.ended(item)
                    if let n = item.next {
                        n.start += c
                        n.end = n.start + n.term
                    }
                    hasRemoveItems = true
                    item.marked = true
                }
            }

            if hasRemoveItems {
                concurrentQueue.async(flags: .barrier) { [weak self] in
                    guard let self = self else { return }
                    let add = NSMutableArray()
                    if hasRemoveItems {
                        for i in (0..<self.items.count).reversed() {
                            let item = self.items[i] as! Item
                            if item.marked {
                                item.block = Item.emptyBlock
                                item.ended = Item.emptyBlock
                                self.items.remove(item)
                                self.itemPool.add(item)
                                if let next = item.next {
                                    add.add(next)
                                }
                            }
                        }
                    }
                    if add.count > 0 {
                        self.items.addObjects(from: add as! [Any])
                    }
                    #if DEBUG
                    print("working items := \(self.items.count) | in pool := \(self.itemPool.count)")
                    #endif
                }
            }
        }

        fileprivate func getItem(_ i: ItemDSL, pause: Pause? = nil) -> Item {
            let item: Item
            if itemPool.count == 0 {
                item = Item()
            } else {
                item = itemPool.lastObject as! Item
                itemPool.removeLastObject()
            }
            return also(item) {
                $0.term  = i.time
                $0.start = i.delay
                $0.loop  = i.isInfinity ? -1 : i.loop
                $0.next  = nil
                $0.isPaused = false
                $0.isTurn   = false
                $0.isStop   = false
                $0.marked   = false
                let ended = i.ended
                $0.block = i.block
                $0.ended = { [weak pause] item in
                    pause?.remove(item: item)
                    ended(item)
                }
                pause?.add(item: $0)
            }
        }

        @discardableResult
        func invoke(pause: Pause? = nil, _ block: (ItemDSL) -> Void) -> Sequence {
            let item = getItem(also(ItemDSL()) { block($0) }, pause: pause)
            item.start += now()
            item.end = item.term == -1.0 ? -1.0 : item.start + item.term
            concurrentQueue.async(flags: .barrier) { [weak self] in
                self?.items.add(item)
            }
            sequence.current = item
            return sequence
        }

        func pause(){
            if (pauseStart == 0.0) { pauseStart = now() }
        }

        func resume(){
            if(pauseStart != 0.0){
                pausedTime += now() - pauseStart
                pauseStart = 0.0
            }
        }
    }

    class Sequence {
        private let looper: Looper
        var current: Item? = nil
        init(looper: Looper) {
            self.looper = looper
        }
        @discardableResult
        func next(pause: Pause? = nil, block: (Looper.ItemDSL) -> Void) -> Sequence {
            let item = looper.getItem(also(Looper.ItemDSL()) { block($0) }, pause: pause)
            current?.next = item
            current = item
            return self
        }
        @discardableResult
        fileprivate func root(pause: Pause? = nil, block: (Looper.ItemDSL) -> Void) -> Sequence {
            let item = looper.getItem(also(Looper.ItemDSL()) { block($0) }, pause: pause)
            current = item
            return self
        }
    }
}

fileprivate let PI  = Double.pi
fileprivate let HPI = Double.pi / 2
extension Looper.Item {
    
    func linear(from: Double, to: Double) -> Double {
        return from + rate * (to - from)
    }
    func sineIn(from: Double, to: Double) -> Double {
        let b = to - from
        return -b * cos(rate * HPI) + b + from
    }
    func sineOut(from: Double, to: Double) -> Double {
        return (to - from) * sin(rate * HPI) + from
    }
    func sineInOut(from: Double, to: Double) -> Double {
        return 0.5 * -(to - from) * (cos(PI * rate) - 1) + from
    }
    func circleIn(from: Double, to: Double) -> Double {
        return -(to - from) * (sqrt(1 - rate * rate) - 1) + from
    }
    func circleOut(from: Double, to: Double) -> Double {
        let a = rate - 1
        return (to - from) * sqrt(1 - a * a) + from
    }
    func circleInOut(from: Double, to: Double) -> Double {
        var a = rate * 2
        let b = to - from
        if (1 > a) {
            return 0.5 * -b * (sqrt(1 - a * a) - 1) + from
        } else {
            a -= 2.0
            return 0.5 * b * (sqrt(1 - a * a) + 1) + from
        }
    }

}

protocol WeakContextHasable {
    var context: AnyObject? { get }
}
class WeakContextContainer {
    static let shared = WeakContextContainer()
    private static let period: Double = 2.0 // 2초 주기
    private var targets = [WeakContextHasable]()
    init() {
        looper.invoke { (dsl) in
            dsl.isInfinity = true
            dsl.block = { item in
                item.start += WeakContextContainer.period
                for i in (0..<self.targets.count).reversed() {
                    if self.targets[i].context == nil {
                        self.targets.remove(at: i)
                    }
                }
                #if DEBUG
//                print("live context counts := \(self.targets.count)")
                #endif
            }
        }
    }
    func add(_ weakObj: WeakContextHasable) {
        targets.append(weakObj)
    }
}

class Funnel: WeakContextHasable {

    typealias Fulfill = (Completion) -> Void
    
    class Completion {
        static let EMPTY = Completion(action: { })
        var action: VoidClosure
        var name: String = "empty"
        func set(name: String) -> Completion {
            self.name = name
            return self
        }
        init(action: @escaping VoidClosure) {
            self.action = action
        }
    }
    fileprivate class Block {
        static let TypeNext = "next"
        static let TypePhase = "phase"
        let type: String
        let body1: ((@escaping Fulfill) -> Void)?
        let body2: (() -> Funnel)?
        init(type: String, body1: ((@escaping Fulfill) -> Void)? = nil, body2: (() -> Funnel)? = nil) {
            self.type = type
            self.body1 = body1
            self.body2 = body2
        }
    }
    fileprivate var blocks = [Block]()
    internal weak var context: AnyObject?
    private var current: Looper.Item!
    init(context: AnyObject? = nil) {
        self.context = context
        WeakContextContainer.shared.add(self)
    }
    @discardableResult
    func next(body: @escaping (@escaping Fulfill) -> Void) -> Funnel {
        blocks.append(Funnel.Block(type: Block.TypeNext, body1: body))
        return self
    }
    @discardableResult
    func phase(body: @escaping () -> Funnel) -> Funnel {
        blocks.append(Funnel.Block(type: Block.TypePhase, body2: body))
        return self
    }

    private var active = false
    private func _start() {
        var seq: Looper.Sequence!
        var next: Funnel?
        while blocks.count > 0 {
            let block = blocks.removeFirst()
            if block.type == Block.TypeNext {
                let body = block.body1!
                if current == nil {
                    seq  = looper.invoke(getDSLBlock(body))
                    current = seq.current!
                } else {
                    seq = seq.root(block: getDSLBlock(body))
                    current.next = seq.current!
                    current = seq.current!
                }
            } else {
                next = block.body2!()
                break
            }
        }
        if let next = next {
            if blocks.count > 0 {
                next.blocks.append(
                    Funnel.Block.init(type: Block.TypePhase, body2: { also(self) { $0.current = nil } })
                )
            }
            if current != nil {
                current.ended = { _ in next._start() }
            } else {
                next._start()
            }
        }
    }
    func start() {
        guard !active else { return }
        active = true
        _start()
    }

    private func getDSLBlock(
        _ body: @escaping (@escaping Fulfill) -> Void
    ) -> (Looper.Looper.ItemDSL) -> Void {
        return { dsl in
            var completion = Completion.EMPTY
            body({ completion = $0 })
            dsl.isInfinity = true
            dsl.block = { item in
                if completion !== Completion.EMPTY {
                    completion.action()
                    item.isStop = true
                }
            }
        }
    }
    deinit {
        print("deinit Funnel")
    }
}

class Watcher {
    class Sequence<Who> where Who: AnyObject {
        weak var who: Who?
        private var _prev: Sequence<Who>?
        private weak var pause: Looper.Pause?
        fileprivate var _invalidate: VoidClosure?
        fileprivate init(who: Who?, pause: Looper.Pause?) { self.who = who; self.pause = pause }
        @discardableResult
        func watch<V>(
            _ keyPath: KeyPath<Who, V>,
            initValue: V? = nil,
            predicate: @escaping (V, V) -> Bool = { $0 != $1 },
            changeHandler: @escaping (Who, (V, V)) -> Void
        ) -> Sequence<Who> where Who: AnyObject, V: Equatable {
            _invalidate = Watcher.watch(pause: pause, who: who, keyPath, initValue: initValue, predicate: predicate, changeHandler: changeHandler)
            return also(Sequence(who: who, pause: pause)) { [weak self] in
                $0._prev = self
                $0._invalidate = self?._invalidate
            }
        }
        func invalidate() {
            _invalidate?()
        }
        func invalidateAll() {
            invalidate()
            _prev?.invalidateAll()
        }
    }
    static func who<Who>(_ who: Who?, pause: Looper.Pause? = nil) -> Sequence<Who> where Who: AnyObject {
        return Sequence(who: who, pause: pause)
    }
    @discardableResult
    private static func watch<Who, V>(
        pause: Looper.Pause?,
        who: Who?,
        _ keyPath: KeyPath<Who, V>,
        initValue: V? = nil,
        predicate: @escaping (V, V) -> Bool = { $0 != $1 },
        changeHandler: @escaping (Who, (V, V)) -> Void
    ) -> VoidClosure where Who: AnyObject, V: Equatable  {
        var isFinish = false
        looper.invoke(pause: pause) { [weak who] (dsl) in
            var oVal = initValue ?? who?[keyPath: keyPath]
            dsl.isInfinity = true
            dsl.block = { (item) in
                guard !isFinish else { item.isStop = true; return }
                switch who {
                case .none: item.isStop = true
                case .some(let who):
                    let nVal = who[keyPath: keyPath]
                    if let _oVal = oVal, predicate(_oVal, nVal) {
                        changeHandler(who, (_oVal, nVal))
                        oVal = nVal
                    }
                }
            }
            dsl.ended = { _ in
//                print("watch finished")
            }
        }
        return { isFinish = true }
    }
}
