//
//  Data_Extension.swift
//  iOS_SandBox
//
//  Created by Taehyeon Jake Lee on 02/05/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation

extension Data {
    func json() -> Any? {
        return try? JSONSerialization.jsonObject(with: self, options: [])
    }
}
