//
//  TestInformationVC.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 01/09/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

class TestInformationVC: UIViewController, VCInitializer {
    static func instance() -> UIViewController {
        return UINib(nibName: "TestInformationVC", bundle: nil)
            .instantiate(withOwner: nil, options: nil)
            .first as! UIViewController
    }
}
