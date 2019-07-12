//
//  Funcs.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 11/07/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

@discardableResult
func also<T>(_ obj: T, _ block: (inout T)->Void) -> T
{
    var copy = obj
    block(&copy)
    return copy
}

func map<T, U>(_ obj: T, _ block: (T) -> U) -> U {
    return block(obj)
}
