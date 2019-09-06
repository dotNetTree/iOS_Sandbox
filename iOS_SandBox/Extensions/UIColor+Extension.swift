//
//  UIColor+Extension.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 04/09/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    typealias ColorElements = (red: CGFloat, green: CGFloat, blue: CGFloat)
    private static func getColorElements(hexString: String) -> ColorElements? {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard
            let targetSub = hexString.split(separator: "#").last,
            targetSub.count == 6
            else { return nil }
        let target = String(targetSub)
        let scanner = Scanner(string: target)
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        return (red, green, blue)
    }

    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255

        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }

    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    convenience init?(startHexString: String, endHexString: String, progress: CGFloat, alpha: CGFloat = 1.0) {
        guard
            let startElements = UIColor.getColorElements(hexString: startHexString),
            let endElements   = UIColor.getColorElements(hexString: endHexString)
            else { return nil }
        let gapElements = (
            red  : endElements.red   - startElements.red,
            green: endElements.green - startElements.green,
            blue : endElements.blue  - startElements.blue
        )
        let elements = (
            red  : startElements.red   + (gapElements.red   * progress),
            green: startElements.green + (gapElements.green * progress),
            blue : startElements.blue  + (gapElements.blue  * progress)
        )
        self.init(red: elements.red, green: elements.green, blue: elements.blue, alpha: alpha)
    }

    var image : UIImage {

        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { (context) in
            context.cgContext.setFillColor(self.cgColor)
            context.fill(rect)
        }
    }
}
