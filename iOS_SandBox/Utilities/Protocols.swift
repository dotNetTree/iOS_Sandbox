//
//  Protocols.swift
//  iOS_SandBox
//
//  Created by Taehyeon Jake Lee on 16/05/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation

protocol JSONConvertible {
    func toJSON<T>() -> T?
}
