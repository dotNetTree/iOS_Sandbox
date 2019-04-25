//
//  UINib+Extension.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 08/04/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

extension UINib {

    /// nib 파일로 부터 UIView를 얻는다.
    ///
    /// - Parameter nibName: nib file name
    /// - Returns: nib에 설정된 view
    static func view<T>(nibName: String) -> T? {
        guard !nibName.contains("<") else { return nil }
        return UINib.init(nibName: nibName, bundle: nil)
            .instantiate(withOwner: nil, options: nil).find { $0 is T } as? T
    }

    /// nib 파일로 부터 UIView를 얻는다.
    /// # !주의 - nib file name과 얻으려 하는 view의 class명과 일치 해야 한다. #
    ///
    /// - Returns: nib에 설정된 view
    static func view<T>() -> T? {
        return self.view(nibName: "\(T.self)")
    }

}
