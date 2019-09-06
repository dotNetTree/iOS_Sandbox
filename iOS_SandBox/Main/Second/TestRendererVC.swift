//
//  TestRendererVC.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 01/09/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

class TestRendererVC: UIViewController, VCInitializer {
    static func instance() -> UIViewController {
        return UINib(nibName: "TestRendererVC", bundle: nil)
            .instantiate(withOwner: nil, options: nil)
            .first as! UIViewController
    }

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var containerH: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        let root = also(
                Renderer.Item(
                renderer: ViewRenderer(target: also(UIView()) {
                    $0.backgroundColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1.0)
                })
            )
        ) {
            $0.style.placer = InlinePlacer
            $0.style.width.value  = 320
            $0.style.height.value = "auto"
        }

        let item0 = also(
            Renderer.Item(
                renderer: ViewRenderer(target: also(UIView()) {
                    $0.backgroundColor = UIColor(red: 1, green: 1, blue: 0, alpha: 1.0)
                })
            )
        ) {
            $0.style.width.value  = 200
            $0.style.height.value = 200
            $0.style.backgroundColor.value = "#ffff00"
        }
        root.addItem(item: item0)
        let item1 = also(
            Renderer.Item(
                renderer: ViewRenderer(target: also(UIView()) {
                    $0.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1.0)
                })
            )
        ) {
            $0.style.width.value  = 200
            $0.style.height.value = 200
        }
        root.addItem(item: item1)
        container.addSubview(root.target())
        root.reflow()

        looper.invoke { (dsl) in
            var count = 0
            let t: Double = 30
            dsl.isInfinity = true
            dsl.block = { item in
                count += 1
                if count % Int(t) == 0 {
                    UIView.animate(withDuration: 15 * t / 1000) {
                        item0.style.width.value  = Double.random(in: 0...200) + 100
                        item0.style.height.value = Double.random(in: 0...200) + 100
                        item0.style.backgroundColor.value = { () -> String in
                            let r = String(Int.random(in: 0...155) + 100, radix: 16)
                            let g = String(Int.random(in: 0...155) + 100, radix: 16)
                            let b = String(Int.random(in: 0...155) + 100, radix: 16)
                            return "#\(r)\(g)\(b)"
                        }()
                        item1.style.width.value  = Double.random(in: 0...200) + 100
                        item1.style.height.value = Double.random(in: 0...200) + 100
                        item0.reflow()
                    }
                    self.containerH.constant = CGFloat(root.offset.h)
                    UIView.animate(withDuration: 15 * t / 1000) {
                        self.parent?.view.layoutIfNeeded()
                    }
                    count = 0
                }
            }

        }
    }

}
