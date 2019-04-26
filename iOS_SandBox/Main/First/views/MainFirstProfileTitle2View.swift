//
//  MainFirstProfileTitle2View.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 25/04/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

class MainFirstProfileTitle2View: UIView, PlugguableViewProtocol {
    typealias Model = MainFirstProfileTitle2VM
    var current: ViewState<Model>?
    var pending: ViewState<Model>?

    var click: ((_ up: Bool) -> Void)!

    @IBOutlet weak var lbTitle: UILabel!
}


extension Renderable where Self: MainFirstProfileTitle2View {
    func _render() {
        guard let pending = pending else { return }
        switch pending {
        case .show(let vm):
            isHidden = false
            lbTitle.text = vm.title
        default:
            isHidden = true
        }
    }
}


struct MainFirstProfileTitle2VM: Equatable {
    let title: String
}
