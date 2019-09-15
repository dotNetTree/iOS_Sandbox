//
//  TestXibView.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 07/09/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        return self.systemLayoutSizeFitting(
            CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
    }
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        return self.systemLayoutSizeFitting(
            CGSize(width: CGFloat.greatestFiniteMagnitude, height: height),
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .required
        ).width
    }
}

class TestXibView: UIView {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
}
