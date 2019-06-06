//
//  Main.Resolver.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 08/04/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation

protocol Resolver {
    associatedtype EC
    associatedtype ATVS
    func run(ec: EC) -> ATVS
}

protocol FirstEntityCollectionResolver: Resolver
    where EC == FirstEntityCollection,
        ATVS == PaddingVM<ViewState<
                    SectionVM<
                        MainFirstProfileTitle2View.Model,
                        MainFirstProfileContentView.Model,
                        MainFirstProfileBottomView.Model
                    >
                >> {
}

extension MainPackage {
    class MainSection: FirstEntityCollectionResolver {
        func run(ec: EC) -> ATVS {
            let name = ec.person.name
            let age  = ec.person.age

            let head = MainFirstProfileTitle2VM(title: "\(age)세 어떤 누군가의 Profile")
            let body = MainFirstProfileContentVM(
                name: name.trimmingCharacters(in: CharacterSet.whitespaces),
                age: "\(age)세"
            )
            let tail = MainFirstProfileBottomVM(title: "다른 사람 검색 해보기... >")
            return
                PaddingVM(
                    .show(SectionVM(.show(head), .show(body), .show(tail), spacing: (100, 20))),
                    spacing: (top: 0.0, left: 20, bottom: 40, right: 50)
            )
        }
    }
}
