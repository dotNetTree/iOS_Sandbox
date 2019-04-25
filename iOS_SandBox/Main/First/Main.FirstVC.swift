//
//  Main.FirstVC.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 07/04/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

enum MainPackage {
    typealias VC = MainFirstVC
    @discardableResult
    static func factory(vc: VC) -> VC? {
        vc.model    = MainPackage.PersonModel(observer: vc)
//        vc.resolver = Resolver(storage: vc.model)
        return vc
    }
}

class MainFirstVC: UIViewController, ThrottleObserver {
    @IBOutlet weak var container: UIStackView!

    let section1 = VSectionView<MainFirstProfileTitleView, MainFirstProfileContentView, MainFirstProfileBottomView>()

    var model: FirstBusinessLogic!
//    var resolver: Resolver<FirstEntityCollection, MainPackage.At>!

    override func viewDidLoad() {
        super.viewDidLoad()
        MainPackage.factory(vc: self)

        section1.body.click = { [weak self] add in
            self?.model.age(add: add)
        }
        section1.tail.click = { print("next page gogogo...") }

        container.addArrangedSubview(section1)
        model.throttle(open: true)
        model.throttle(open: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        model.throttle(open: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        model.throttle(open: false)
    }

    func updated() {
        section1.set(with: MainPackage.Test().run(ec: model))
        section1.render()
    }
}
