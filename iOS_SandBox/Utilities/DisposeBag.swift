//
//  DisposeBag.swift
//  iOS_SandBox
//
//  Created by Taehyeon Jake Lee on 02/05/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation

protocol Disposable {
    func dispose()
}
extension Disposable {
    @discardableResult
    func disposed(by bag: DisposeBag) -> Self {
        bag.insert(self)
        return self
    }
}

class DisposeBag {
    var disposables = [Disposable]()

    func insert(_ disposable: Disposable) {
        disposables.append(disposable)
    }

    private func disposeAll() {
        while disposables.count > 0 {
            disposables.removeFirst().dispose()
        }
    }

    deinit {
        disposeAll()
    }
}

protocol DisposeBase {
    var disposeBag: DisposeBag { get }
}
