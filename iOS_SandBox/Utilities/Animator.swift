//
//  Animator.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 12/08/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}

enum Animator { }
extension Animator {
    class Flip<View> where View: UIView {
        private var v1: View
        private var v1Cover: UIView
        private var v2: View
        private var v2Cover: UIView
        init(current: View, next: View) {
            self.v1 = current
            self.v2 = next
            v1Cover = UIView(frame: v1.bounds)
            v1Cover.isUserInteractionEnabled = false
            v1Cover.backgroundColor = .black
            v1Cover.alpha = 0
            v1Cover.layer.cornerRadius = v1.layer.cornerRadius
            v1.addSubview(v1Cover)

            v2Cover = UIView(frame: v2.bounds)
            v2Cover.isUserInteractionEnabled = false
            v2Cover.backgroundColor = .black
            v2Cover.alpha = 0
            v2Cover.layer.cornerRadius = v2.layer.cornerRadius
            v2.addSubview(v2Cover)
        }
        func animate(completion: () -> Void) {
            let m34: CGFloat = 1 / -200
            let duration: Double = 2
            var transform = CATransform3DIdentity
            transform.m34 = m34
            transform = CATransform3DRotate(transform, 0, 1, 0, 0)  // x 축으로 돌린다.
            v1.layer.transform = CATransform3DScale(transform, 1, -1, 1)
            v2.layer.transform = transform
            v1.layer.zPosition = 0
            v2.layer.zPosition = 1
            v1Cover.alpha = 0
            v2Cover.alpha = 0
            let iv1 = UIImageView(frame: CGRect.init(
                origin: CGPoint(x: v1.frame.origin.x, y: v1.frame.origin.y),
                size: CGSize(width: v1.frame.size.width, height: v1.frame.size.height / 2)
                )
            )
            v1.superview?.insertSubview(iv1, at: 0)
            iv1.image = v1.asImage()
            iv1.contentMode = .top
            iv1.clipsToBounds = true

            let iv2 = UIImageView(
                frame: CGRect.init(
                    origin: CGPoint(x: v2.frame.origin.x, y: v2.frame.origin.y + v2.frame.size.height / 2),
                    size: CGSize(width: v2.frame.size.width, height: v2.frame.size.height / 2)
                )
            )  // 상단에 있는 view
            v1.superview?.insertSubview(iv2, at: 1)
            iv2.image = v2.asImage()
            iv2.contentMode = .bottom
            iv2.clipsToBounds = true

            let toHalf: UIViewPropertyAnimator
            var toEnd:  UIViewPropertyAnimator? = nil

            toHalf = UIViewPropertyAnimator(
                duration: duration / 2, curve: .linear
            ) {
                var transform = CATransform3DIdentity
                transform.m34 = m34
                transform = CATransform3DRotate(transform, -CGFloat.pi / 2, 1, 0, 0)
                self.v1.layer.transform = CATransform3DScale(transform, 1, -1, 1)
                self.v2.layer.transform = transform
                self.v1Cover.alpha = 0.5
                self.v2Cover.alpha = 0.5
            }
            toHalf.addCompletion { (_) in
                self.v1.layer.zPosition = 1
                self.v2.layer.zPosition = 0
                toEnd?.startAnimation()
            }
            toHalf.startAnimation()

            toEnd = UIViewPropertyAnimator(
                duration: duration / 2, curve: .linear
            ) {
                var transform = CATransform3DIdentity
                transform.m34 = m34
                transform = CATransform3DRotate(transform, -CGFloat.pi, 1, 0, 0)
                self.v1.layer.transform = CATransform3DScale(transform, 1, -1, 1)
                self.v2.layer.transform = transform
                self.v1.layer.zPosition = 1
                self.v2.layer.zPosition = 0
                self.v1Cover.alpha = 0
                self.v2Cover.alpha = 0
            }
            toEnd?.addCompletion { (_) in
                self.v1.layer.transform = CATransform3DIdentity
                self.v2.layer.transform = CATransform3DIdentity
                self.v1.layer.zPosition = 0
                self.v2.layer.zPosition = 0
                iv1.removeFromSuperview()
                iv2.removeFromSuperview()
            }
        }
    }
}
