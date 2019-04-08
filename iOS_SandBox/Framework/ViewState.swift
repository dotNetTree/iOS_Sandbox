//
//  ViewState.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 07/04/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation

enum ViewState<VM: Equatable>: Equatable {
    case hidden
    case fail(String)
    case loading
    case show(VM)
    static func == (lhs: ViewState<VM>, rhs: ViewState<VM>) -> Bool {
        switch (lhs, rhs) {
        case (.hidden, .hidden):   return true
        case (.loading, .loading): return true
        case let (.fail(e1), .fail(e2)) where e1 == e2: return true
        case let (.show(e1), .show(e2)) where e1 == e2: return true
        default:
            return false
        }
    }
}
