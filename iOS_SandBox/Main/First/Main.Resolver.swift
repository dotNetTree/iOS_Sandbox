//
//  Main.Resolver.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 08/04/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation

protocol FirstEntityCollectionResolverAt {
    associatedtype ATVS
    associatedtype EC
    func run<ATVS>(ec: EC) -> ATVS
}

extension MainPackage {
    class Test<T>: FirstEntityCollectionResolverAt where T == ViewState<SectionVM<
        MainFirstProfileTitleView.Model, MainFirstProfileContentView.Model, MainFirstProfileBottomView.Model
    >> {
        typealias ATVS = T
        typealias EC = FirstEntityCollection
        func run<ATVS>(ec: EC) -> ATVS {
            guard !PersonEntity.isEmpty(p: ec.person) else { return .hidden }
            let name = ec.person.name
            let age  = ec.person.age
            let head = MainFirstProfileTitleView.Model(title: "\(age)세 어떤 누군가의 Profile")
            let body = MainFirstProfileContentView.Model(
                name: name.trimmingCharacters(in: CharacterSet.whitespaces),
                age: "\(age)세"
            )
            let tail = MainFirstProfileBottomView.Model(title: "다른 사람 검색 해보기... >")
            return .show(SectionVM(.show(head), .show(body), .show(tail), spacing: (100, 20)))
        }
    }
}

//extension Resolver where EC == FirstEntityCollection, At == MainPackage.At {
//
//    func resolve<EC>(at: At) -> EC? {
//        return at.run()
//    }
//
//}
