//
//  Looper.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 09/07/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

fileprivate let UP_FRAME   = CGRect(x: -100, y: -101, width: 1, height: 1)
fileprivate let DOWN_FRAME = CGRect(x: -100, y: -100, width: 1, height: 1)

fileprivate typealias Now = () -> Double
fileprivate let now: Now = { Date.timeIntervalSinceReferenceDate }

protocol LooperOscillator {
    var loopers: [Looper.Looper] { get set }
    func act()
}
enum Looper {
    private class Oscillator2: LooperOscillator {
        lazy var displayLink: CADisplayLink? = { [weak self] in
            guard let self = self else { return nil }
            return CADisplayLink(target: self, selector: #selector(update))
        }()
        var loopers = [Looper]()
        func act() {
            displayLink?.add(to: .main, forMode: .default)
        }
        @objc func update() {
            loopers.forEach { $0.loop() }
        }
    }
    private class Oscillator: UIView, LooperOscillator {
        let serialQueue = DispatchQueue(label: "com.chela.lopper.oscillator.queue")
        var loopers = [Looper]()
        var isActing = false
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        override func draw(_ rect: CGRect) {
            loopers.forEach { $0.loop() }
        }
        func act() {
            guard isActing == false else { return }
            isActing = true
            serialQueue.async { [weak self] in
                guard let self = self else { return }
                while true {
                    usleep(15000)
                    DispatchQueue.main.sync {
                        self.frame = self.frame == UP_FRAME ? DOWN_FRAME : UP_FRAME
                        self.setNeedsDisplay()
                    }
                }
            }
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
        private var items    = [Item]()
//        private var remove   = [Item]()
        private var hasRemoveItems = false
        private var add      = [Item]()
        private var itemPool = [Item]()

        private static var oscillator = { () -> LooperOscillator in
//            let oscillator = Oscillator(frame: UP_FRAME)
//            UIApplication.shared.delegate?.window??.addSubview(oscillator)
            let oscillator = Oscillator2()
            return oscillator
        }()

        private lazy var _sequence = Sequence(looper: self)
        private var sequence: Sequence {
            get { return _sequence }
        }

        func act() {
            Looper.oscillator.loopers += [self]
            Looper.oscillator.act()
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
            guard !items.isEmpty else { return }
            hasRemoveItems = false
            add.removeAll()

            concurrentQueue.sync {
                var i = 0
                while i < items.count {
                    let item = items[i]
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
                            add.append(n)
                        }
                        hasRemoveItems = true
                        item.marked = true
                    }
                }
            }

            if hasRemoveItems || !add.isEmpty {
                concurrentQueue.async(flags: .barrier) { [weak self] in
                    guard let self = self else { return }
                    if self.hasRemoveItems {
                        for i in (0..<self.items.count).reversed() {
                            let item = self.items[i]
                            if item.marked {
                                self.items.remove(at: i)
                                self.itemPool.append(item)
                            }
                        }
//                        for i in stride(from: (self.items.count - 1), through: 0, by: -1) {
//                            let item = self.items[i]
//                            if item.marked {
//                                self.items.remove(at: i)
//                                self.itemPool.append(item)
//                            }
//                        }
                    }
                    if !self.add.isEmpty {
                        self.items = self.items + self.add
                    }
                    print("itemPool count := \(self.itemPool.count)")
                }
            }
        }

        func getItem(_ i: ItemDSL) -> Item {
            return also(itemPool.count == 0 ? Item() : itemPool.removeLast()) {
                $0.term  = i.time
                $0.start = i.delay
                $0.loop  = i.isInfinity ? -1 : i.loop
                $0.block = i.block
                $0.ended = i.ended
                $0.next  = nil
                $0.isStop = false
                $0.marked = false
            }
        }

        @discardableResult
        func invoke(_ block: (ItemDSL) -> Void) -> Sequence {
            let item = getItem(also(ItemDSL()) { block($0) })
            item.start += now()
            item.end = item.term == -1.0 ? -1.0 : item.start + item.term
            concurrentQueue.sync(flags: .barrier) { [weak self] in
                self?.items.append(item)
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
        func next(block: (Looper.ItemDSL) -> Void) -> Sequence {
            let item = looper.getItem(also(Looper.ItemDSL()) { block($0) })
            current?.next = item
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
