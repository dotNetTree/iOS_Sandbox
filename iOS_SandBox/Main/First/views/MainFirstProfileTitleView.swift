//
//  MainFirstProfileTitleView.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 25/04/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

struct Title: Equatable {
    let val: String
}
struct Name: Equatable {
    let val: String
}

struct Compose: Equatable {
    let title: Title
    let name: Name
}

class MainFirstProfileTitleView: UIView {
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbTitle2: UILabel!
    @IBOutlet weak var btnTest: UIButton!
}

class ViewWrapper<View, Model>: Renderable where View: UIView, Model: Equatable {
    var current: Model?
    var pending: Model?
    let view: View
    init() {
        self.view = UINib.view() ?? View.init()
    }
    func set(with model: Model?) {
        pending = model
    }
    func render() {
        guard let pending = pending else { return }
        if let current = current, current == pending { return }
        _render()
        self.pending = nil
        self.current = pending
    }
    func _render() {
        print("[Abstract] \(self) render를 구현해주세요!")
    }
    func _render(with model: Any) {
        guard let model = model as? Model else { return }
        set(with: model)
        render()
    }
}

extension Renderable
    where Self: ViewWrapper<MainFirstProfileTitleView, ViewState<Title>> {
    func _render() {
        guard let pending = pending else { return }
        switch pending {
        case .show(let vm):
            view.isHidden = false
            view.lbTitle.text = vm.val
        default:
            view.isHidden = true
        }
    }
}

//extension Renderable where Self: MainFirstProfileTitleView {
//    func _render() {
//        guard let pending = pending else { return }
//        switch pending {
//        case .show(let vm):
//            isHidden = false
//            lbTitle.text = vm.title
//        default:
//            isHidden = true
//        }
//    }
//}


