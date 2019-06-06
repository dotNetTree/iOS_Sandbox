//
//  MainFirstProfileContentView.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 08/04/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

class MainFirstProfileContentView: UIView, PlugguableViewProtocol {
    typealias Model = ViewState<MainFirstProfileContentVM>
    var current: Model?
    var pending: Model?

    var click: ((_ up: Bool) -> Void)!

    @IBOutlet weak var lbName:   UILabel!
    @IBOutlet weak var lbAge:    UILabel!
    @IBOutlet weak var btnPlus:  UIButton! { didSet { btnPlus.addAction { [weak self] (_) in self?.click(true) } } }
    @IBOutlet weak var btnMinus: UIButton! { didSet { btnMinus.addAction { [weak self] (_) in
        self?.click(false)
        
        } } }
}

extension Renderable where Self: MainFirstProfileContentView {
    func _render() {
        guard let pending = pending else { return }
        switch pending {
        case .show(let vm):
            isHidden = false
            lbName.text = vm.name
            lbAge.text  = vm.age
        default:
            isHidden = true
        }
    }
}

struct MainFirstProfileContentVM: Equatable {
    let name: String
    let age: String
}
