//
//  Dictionary+Extension.swift
//  iOS_SandBox
//
//  Created by Taehyeon Jake Lee on 16/05/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation

public func ==<K:Hashable, V>(lhs: [K: V], rhs: [K: V] ) -> Bool {
    return (lhs as NSDictionary).isEqual(to: rhs)
}
extension Dictionary {

    func extend(_ other: Dictionary?) -> Dictionary {
        var origin = self

        if let other = other {
            for (key, value) in other {
                origin.updateValue(value, forKey: key)
            }
        }

        return origin
    }

    func extend(_ key: Key, _ val: Value?) -> Dictionary {

        if let v = val {
            return self.extend([key: v])
        } else {
            return self
        }
    }

    func findBy(_ keys: Key...) -> Value? {
        for key in keys {
            if let val = self[key] {
                return val
            }
        }
        return nil
    }
}

extension Dictionary: JSONConvertible {
    func toJSON<T>() -> T? {
        return self as? T
    }
}
