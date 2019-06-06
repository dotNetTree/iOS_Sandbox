//
//  Log.swift
//  iOS_SandBox
//
//  Created by Taehyeon Jake Lee on 16/05/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation

fileprivate let logDispatchQueue = DispatchQueue(label: "YALOG_AND_YAPRINT")

func ChLog(_ format: String, _ args: CVarArg..., file: String = #file, line: Int = #line, function: String = #function) {
    #if DEBUG
    logDispatchQueue.async {
        let url = URL(fileURLWithPath: file)
        let realMsg = String(format: format, arguments: args)
        let msg = "[\(url.lastPathComponent) : \(line) | \(function)] : \(realMsg)"
        NSLog(msg)
    }
    #endif
}

func ChPrint(_ items: Any..., file: String = #file, line: Int = #line, function: String = #function, separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    logDispatchQueue.async {
        let url = URL(fileURLWithPath: file)
        let codeInfo = "[\(url.lastPathComponent) : \(line) | \(function)] :"
        var items = items
        items.insert(codeInfo, at: 0)
        for item in items {
            print(item, terminator: " ")
        }
        print("")
    }
    #endif
}
