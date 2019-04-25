//
//  Main.Model.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 08/04/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation

protocol FirstEntityCollection {
    var person: MainPackage.PersonEntity { get }
}
protocol FirstBusinessLogic: FirstEntityCollection, Throttle {
    func age(add: Bool)
}

extension MainPackage {
    struct PersonEntity: Equatable, Codable {
        static let empty: PersonEntity = PersonEntity(name: "", age: 0)
        static func isEmpty(p:PersonEntity) -> Bool {
            return p == PersonEntity.empty
        }
        var name: String
        var age: Int
    }

    class PersonModel: FirstBusinessLogic {
        weak var observer: ThrottleObserver!
        var isOpening = false

        var person: PersonEntity = PersonEntity.empty
        init(observer: ThrottleObserver) {
            self.observer = observer
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self else { return }
                self.person = PersonEntity(name: "강승철", age: 39)
                self.push()
            }
        }
        func age(add: Bool) {
            if PersonEntity.isEmpty(p: self.person){ return }
            self.person.age += add ? 1 : -1
            push()
        }
    }
}

