//
//  AppDelegate.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 07/04/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import UIKit

extension String {
    var isBlank: Bool {
        return self.trimmingCharacters(in: .whitespaces).isEmpty
    }
    func substring(_ r: Range<Int>?) -> String {
        guard let r = r else { return self }
        let fromIndex  = self.index(self.startIndex, offsetBy: r.lowerBound)
        let toIndex    = self.index(self.startIndex, offsetBy: r.upperBound)
        let indexRange = Range<String.Index>(uncheckedBounds: (lower: fromIndex, upper: toIndex))
        return String(self[indexRange])
    }
    func replace(_ target: String, _ with: String) -> String {
        return self.replacingOccurrences(of: target, with: with)
    }
    func replace(pattern: String, _ with: String) -> String {
        return self.replace(pattern: pattern, { _,_ in with })
    }
    func replace(pattern: String, _ predicate: (String, NSTextCheckingResult) -> String) -> String {
        guard let matchs = (try? NSRegularExpression(pattern: pattern))?
            .matches(in: self, range: NSRange(self.startIndex..., in: self)) else {
                return self
        }
        var prev = 0
        return matchs.reduce("") { (accu, curr) -> String in
            let lower = curr.range.lowerBound
            let upper = curr.range.upperBound
            defer { prev = upper }
            return accu
                + self.substring(
                    Range(uncheckedBounds: (lower: prev, upper: lower))
                )
                + predicate(self, curr)
        }
        + self.substring(
            Range(uncheckedBounds: (lower: prev, upper: self.count))
        )
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let cleanUp = #"[^.\d-+*\/]"#
        let mulDiv = #"((?:\+-)?[.\d]+)([*\/])((?:\+-)?[.\d]+)"#
        let paren  = #"\(([^()]*)\)"#
        let ex = { (v: String) -> Double in
            v.replace(pattern: cleanUp, "")
            .replace("-", "+-")
            .replace(pattern: mulDiv) { (o, r) in
                let (left, op, right) = (
                    o.substring(Range(r.range(at: 1))).replace("+", ""),
                    o.substring(Range(r.range(at: 2))),
                    o.substring(Range(r.range(at: 3))).replace("+", "")
                )
                let l = Double(left)!
                let r = Double(right)!
                return "\(op == "*" ? l * r : l / r)".replace("-", "+-")
            }
            .components(separatedBy: "+")
            .reduce(0.0) { $0 + ($1.isBlank ? 0.0 : Double($1)!) }
        }
        let calc = { (v: String) -> Double in
            var v = v
            guard let regex = try? NSRegularExpression(pattern: paren) else {
                return 0.0
            }
            while regex.firstMatch(in: v, options: [], range: NSRange.init(location: 0, length: v.count - 1)) != nil {
                v = v.replace(pattern: paren, { (o, r) -> String in
                    "\(ex(o.substring(Range(r.range(at: 1)))))"
                })
            }
            return ex(v)
        }

        print(calc("1 +   3 * (-2 + 4) + 6. ")) // result 13.0

        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

