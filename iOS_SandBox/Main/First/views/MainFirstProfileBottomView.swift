//
//  MainFirstProfileBottomView.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 25/04/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation

import UIKit

class MainFirstProfileBottomView: UIView, PlugguableViewProtocol {
    typealias Model = MainFirstProfileBottomVM
    var current: ViewState<Model>?
    var pending: ViewState<Model>?

    var click: (() -> Void)!

    @IBOutlet weak var btnNext:  UIButton! { didSet { btnNext.addAction { [weak self] (_) in self?.click() } } }
}

extension Renderable where Self: MainFirstProfileBottomView {
    func _render() {
        guard let pending = pending else { return }
        switch pending {
        case .show(let vm):
            isHidden = false
            btnNext.setTitle(vm.title, for: .normal)
        default:
            isHidden = true
        }
    }
}

struct MainFirstProfileBottomVM: Equatable {
    let title: String
}
