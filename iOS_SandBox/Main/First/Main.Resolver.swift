//
//  Main.Resolver.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 08/04/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation

extension MainPackage {
    enum At {
        case profile
    }
}

extension Resolver where Storage == FirstStorage, At == MainPackage.At {

    func resolve<T>(at: At) -> T? {
        switch at {
        case .profile: return profile() as? T
        }
    }

    private func profile() -> ViewState<MainFirstProfileVM> {
        guard let name = storage.name, let age = storage.age, age >= 0 else { return .hidden }
        return .show(
            MainFirstProfileVM(
                name: name.trimmingCharacters(in: CharacterSet.whitespaces),
                age: "\(age)세"
            )
        )
    }

}
