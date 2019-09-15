//
//  TestNaviVC.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 01/09/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

class TestNaviVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TestNaviVC")

//        looper.invoke { [weak self] (dsl) in
//            guard let self = self else { return }
//            dsl.block = { [weak self] item in
//                guard let self = self else { item.isStop = true; return }
//                guard let parentView = self.parent?.view else { return }
//                showParticle(target: parentView)
//                item.isStop = true
//            }
//        }
    }
}

class TestANaviVC: TestNaviVC, VCInitializer {
    static func instance() -> UIViewController {
        return UINib(nibName: "TestANaviVC", bundle: nil)
            .instantiate(withOwner: nil, options: nil)
            .first as! UIViewController
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TestANaviVC")
    }
}

class TestBNaviVC: TestNaviVC, VCInitializer {
    static func instance() -> UIViewController {
        return UINib(nibName: "TestBNaviVC", bundle: nil)
            .instantiate(withOwner: nil, options: nil)
            .first as! UIViewController
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TestBNaviVC")
    }
}
