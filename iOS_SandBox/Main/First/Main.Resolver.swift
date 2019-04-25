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
        case test
    }
}

extension Resolver where Storage == FirstStorage, At == MainPackage.At {

    func resolve<T>(at: At) -> T? {
        switch at {
        case .test: return test() as? T
        }
    }

    private func test() -> ViewState<SectionVM<
        MainFirstProfileTitleView.Model, MainFirstProfileContentView.Model, MainFirstProfileBottomView.Model
    >> {
        guard let name = storage.name, let age = storage.age, age >= 0 else { return .hidden }
        let head = MainFirstProfileTitleView.Model(title: "\(age)세 어떤 누군가의 Profile")
        let body = MainFirstProfileContentView.Model(
            name: name.trimmingCharacters(in: CharacterSet.whitespaces),
            age: "\(age)세"
        )
        let tail = MainFirstProfileBottomView.Model(title: "다른 사람 검색 해보기... >")
        return .show(SectionVM(.show(head), .show(body), .show(tail), spacing: (100, 20)))
    }

}
