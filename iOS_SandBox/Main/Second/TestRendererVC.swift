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
            $0.style.placer = InlinePlacer
            $0.style.width.value  = "auto"
            $0.style.height.value = "auto"
        }
        let item0_1 = also(
            Renderer.Item(
                renderer: ViewRenderer(target: also(UIView()) {
                    $0.backgroundColor = UIColor(red: 1, green: 0, blue: 1, alpha: 1.0)
                })
            )
        ) {
            $0.style.width.value  = 200
            $0.style.height.value = 200
        }
        let item0_2 = also(
            Renderer.Item(
                renderer: ViewRenderer(target: also(UIView()) {
                    $0.backgroundColor = UIColor(red: 0, green: 1, blue: 1, alpha: 1.0)
                })
            )
        ) {
            $0.style.width.value  = 200
            $0.style.height.value = 200
        }
        root.addItem(item: item0)
        item0.addItem(item: item0_1)
        item0.addItem(item: item0_2)
        item0.reflow()
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
            dsl.isInfinity = true
            dsl.block = { item in
                count += 1
                if count % 40 == 0 {

                    UIView.animate(withDuration: 0.3) {
                        item0_1.style.width.value  = Double.random(in: 0...200) + 30
                        item0_1.style.height.value = Double.random(in: 0...200) + 30
                        item0_2.style.width.value  = Double.random(in: 0...200) + 30
                        item0_2.style.height.value = Double.random(in: 0...200) + 30
                        item1.style.width.value  = Double.random(in: 0...200) + 50
                        item1.style.height.value = Double.random(in: 0...200) + 50
                        item0_1.reflow()
                    }
                    self.containerH.constant = CGFloat(root.offset.h)
                    UIView.animate(withDuration: 0.3) {
                        self.parent?.view.layoutIfNeeded()
                    }
                    count = 0
                }
            }

        }
    }

}
