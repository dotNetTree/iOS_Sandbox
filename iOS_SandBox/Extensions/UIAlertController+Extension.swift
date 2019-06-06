//
//  UIAlertController+Extension.swift
//  iOS_SandBox
//
//  Created by Taehyeon Jake Lee on 02/05/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {

    /// alertcontroller 를 present 하는 function
    ///
    /// - Parameters:
    ///   - viewController: optional
    ///   - title: 상단 타이틀
    ///   - msg: 내용
    ///   - cancelButtonTitle: 취소버튼 좌측
    ///   - destructiveButtonTitle: 우측 강조 ? 버튼
    ///   - otherButtonTitles: 기타버튼
    ///   - handler: 버튼 액션 처리
    static func showAlert(in viewController: UIViewController? = nil,
                          title: String?,
                          msg: String?,
                          cancelButtonTitle: String?,
                          destructiveButtonTitle: String?,
                          otherButtonTitles: String?...,
        handler: ((UIAlertController, UIAlertAction) -> Void)? = nil) {

        let alert = UIAlertController.init(title: title, message: msg, preferredStyle: .alert)
        var buttons = [UIAlertAction]()

        if let cancel = cancelButtonTitle {
            buttons.append(
                UIAlertAction.init(
                    title: cancel,
                    style: .cancel,
                    handler: { handler?(alert, $0) }
                )
            )
        }

        if let destructive = destructiveButtonTitle {
            buttons.append(UIAlertAction.init(title: destructive,
                                              style: .destructive, handler: {
                                                handler?(alert, $0)
            }))
        }

        let others = otherButtonTitles
            .filter { $0 != nil}
            .map {
                UIAlertAction.init(title: $0, style: .default, handler: {
                    handler?(alert, $0)
                })
        }

        (buttons + others)
            .filter { $0.title != nil }
            .forEach {
                alert.addAction($0)
        }

        gf.currentNavigationVC {
            $0.present(alert, animated: true, completion: nil)
        }
    }
}
