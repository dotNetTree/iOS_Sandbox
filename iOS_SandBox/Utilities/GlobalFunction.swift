//
//  GlobalFunction.swift
//  iOS_SandBox
//
//  Created by Taehyeon Jake Lee on 02/05/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

class gf {

    static func currentNavigationVC() -> UINavigationController? {
        return UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
    }

    /// 최상단 navigation controller 를 찾아 반환해준다.
    static func currentNavigationVC(comletion: (UINavigationController) -> Void) {

        guard
            let root  = UIApplication.shared.keyWindow?.rootViewController,
            let naviC = { (vc: UIViewController) -> UINavigationController? in
                var vc: UIViewController? = vc
                while(vc?.presentedViewController != nil) {
                    vc = vc?.presentedViewController
                }
                return vc as? UINavigationController
            }(root)
            else {
                return
        }

        comletion(naviC)

    }

    /// nib 파일로 부터 UIView를 얻는다.
    ///
    /// - Parameter nibName: nib file name
    /// - Returns: nib에 설정된 view
    static func view<T>(nibName: String) -> T? {
        return UINib.view(nibName: nibName)
    }

    /// nib 파일로 부터 UIView를 얻는다.
    /// # !주의 - nib file name과 얻으려 하는 view의 class명과 일치 해야 한다. #
    ///
    /// - Returns: nib에 설정된 view
    static func viewInNib<T>() -> T? {
        return self.view(nibName: "\(T.self)")
    }

    /**
     연속 되는 index 를 갖는 이미지의 animationImage 를 반환한다
     ````
     name : 숫자 앞 이름
     sufixNum : name을 제외한 초기 num을 자릿수에 맞게
     */
    static func animationImages(with start: (name: String, sufixNum: String)) -> [UIImage] {
        var imgName = start.name + start.sufixNum
        var imgs = [UIImage]()
        while let img = UIImage.init(named: imgName) {
            imgs.append(img)
            imgName = String.init(format: "\(start.name)%0\(start.sufixNum.count)d", imgs.count)
        }
        return imgs
    }

    /// 뷰가 가지고 있는 subView들 중 이벤트가 발생되고 있는 뷰를 찾아서 반환
    ///
    /// - Parameter view: 전체 뷰
    /// - Returns: 이벤트가 발생되고 있는 뷰
    static func findFirstResponder(inView view: UIView) -> UIView? {
        for subView in view.subviews {
            if subView.isFirstResponder {
                return subView
            }

            if let recursiveSubView = self.findFirstResponder(inView: subView) {
                return recursiveSubView
            }
        }
        return nil
    }

    /// 현재 Application의 Version을 반환 한다.
    ///
    /// - Returns: appVersion String
    static func getCurrentVersion() -> String? {
        guard
            let appInfo = Bundle.main.infoDictionary,
            let version = appInfo["CFBundleShortVersionString"] as? String
            else { return nil }

        return version
    }

    static func makeAttributeString(strings: [NSAttributedString]) -> NSAttributedString {
        return strings.compactMap { $0 }.reduce(NSMutableAttributedString()) { $0.append($1); return $0 }
    }

}
