//
//  After.swift
//  iOS_SandBox
//
//  Created by Taehyeon Jake Lee on 02/05/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation

typealias VoidClosure = () -> Void

func after(delay seconds: Double = 0.0, closure: @escaping VoidClosure) {
    DispatchQueue.main.asyncAfter(
        deadline: .now() + DispatchTimeInterval.milliseconds(Int(seconds * 1000)),
        execute: closure
    )
}
