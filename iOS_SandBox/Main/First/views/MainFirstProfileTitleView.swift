//
//  MainFirstProfileTitleView.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 25/04/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

class MainFirstProfileTitleView: UIView, PlugguableViewProtocol {
    typealias Model = MainFirstProfileTitleVM
    var current: VS<Model>?
    var pending: VS<Model>?

    var click: ((_ up: Bool) -> Void)!

    @IBOutlet weak var lbTitle: UILabel!
}


extension Renderable where Self: MainFirstProfileTitleView {
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


struct MainFirstProfileTitleVM: Equatable {
    let title: String
}
