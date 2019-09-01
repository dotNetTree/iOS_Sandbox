//
//  TestCode.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 01/09/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

func showParticle(target view: UIView) {

    let sW = UIScreen.main.bounds.size.width
    let sH = UIScreen.main.bounds.size.height
    let halfW = Double(sW / 2)
    let halfH = Double(sH / 2)

    for _ in 1...200 {

        let size = CGFloat.random(in: 3...8.0)
        let r = CGFloat.random(in: 0.3...0.7)
        let g = CGFloat.random(in: 0.3...0.7)
        let b = CGFloat.random(in: 0.3...0.7)

        var x: CGFloat; var y: CGFloat
        switch Int.random(in: 0...3) {
        case 0:  x = 0;  y = CGFloat.random(in: 0...(sH - size))
        case 1:  x = sW - size; y = CGFloat.random(in: 0...(sH - size))
        case 2:  y = 0;  x = CGFloat.random(in: 0...(sW - size))
        default: y = sH - size; x = CGFloat.random(in: 0...(sW - size))
        }

        let dot = also(UIView()) {
            $0.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: 1)
            $0.layer.cornerRadius = size / 2
            $0.isUserInteractionEnabled = false
        }
        view.addSubview(dot)
        dot.translatesAutoresizingMaskIntoConstraints = false
        let leftAnchor   = dot.leftAnchor.constraint(equalTo: view.leftAnchor, constant: sW / 2)
        let topAnchor    = dot.topAnchor.constraint(equalTo: view.topAnchor, constant: sH / 2)
        let widthAnchor  = dot.widthAnchor.constraint(equalToConstant: size)
        let heightAnchor = dot.heightAnchor.constraint(equalToConstant: size)
        NSLayoutConstraint.activate([
            leftAnchor, topAnchor, widthAnchor, heightAnchor
            ])
        let delay = Double.random(in: 0...3)
        let term  = Double.random(in: 0.7...1.5) + 2

        looper.invoke { (dsl) in
            dsl.delay = delay
            dsl.time  = term
            //                    dsl.isInfinity = true
            dsl.block = { [weak dot] item in
                guard let dot = dot else { return }
                switch item.rate {
                case 1:
                    dot.alpha = 0
                default:
                    dot.alpha = CGFloat(item.sineIn(from: 1, to: 0))
                    leftAnchor.constant   = CGFloat(item.sineInOut(from: halfW, to: Double(x)))
                    topAnchor.constant    = CGFloat(item.sineInOut(from: halfH, to: Double(y)))
                    widthAnchor.constant  = CGFloat(item.sineIn(from: Double(size), to: Double(size + 20)))
                    heightAnchor.constant = CGFloat(item.sineIn(from: Double(size), to: Double(size + 20)))
                    dot.layer.cornerRadius = heightAnchor.constant / 2
                }
                //                        item.isStop = true
            }
            //                dsl.ended = { [weak dot] _ in
            //                    print("deleted")
            ////                    dot?.removeFromSuperview()
            //                }
            }.next { (dsl) in
                dsl.delay = delay
                dsl.time  = term
                //                    dsl.isInfinity = true
                dsl.block = { [weak dot] item in
                    guard let dot = dot else { return }
                    switch item.rate {
                    case 1:
                        dot.alpha = 0
                    default:
                        dot.alpha = CGFloat(item.sineIn(from: 0, to: 1))
                        leftAnchor.constant   = CGFloat(item.sineInOut(from: Double(x) , to: halfW))
                        topAnchor.constant    = CGFloat(item.sineInOut(from: Double(y) , to: halfH))
                        widthAnchor.constant  = CGFloat(item.sineIn(from: Double(size + 20) , to: Double(size)))
                        heightAnchor.constant = CGFloat(item.sineIn(from: Double(size + 20), to: Double(size)))
                        dot.layer.cornerRadius = heightAnchor.constant / 2
                    }
//                        item.isStop = true
                }
        }

    }

}
