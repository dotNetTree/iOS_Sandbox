//
//  Main.Model.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 08/04/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation

protocol FirstStorage {
    var name: String? { get }
    var age: Int? { get }
}
protocol FirstBusinessLogic: FirstStorage, Throttle {
    func age(add: Bool)
}

extension MainPackage {
    class Model: FirstBusinessLogic {
        var name: String?
        var age: Int?
        weak var observer: ThrottleObserver!
        var isOpening = false
        init(observer: ThrottleObserver) {
            self.observer = observer
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self else { return }
                self.name = "강승철"
                self.age  = 39
                self.push()
            }
        }

        func age(add: Bool) {
            guard let _age = age else { return }
            let inc = _age + (add ? +1 : -1)
            age = inc < 0 ? 0 : inc
            push()
        }
    }
}

