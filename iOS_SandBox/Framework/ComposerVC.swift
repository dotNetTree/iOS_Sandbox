//
//  ComposerVC.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 30/08/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

typealias VCFactory = () -> UIViewController
protocol VCInitializer: AnyObject {
    static func instance() -> UIViewController
}
typealias ITZ = UIViewController & VCInitializer


func stringClassFromString(_ className: String) -> AnyClass! {

    /// get namespace
    let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String;

    /// get 'anyClass' with classname and namespace
    let cls: AnyClass = NSClassFromString("\(namespace).\(className)")!;

    // return AnyClass!
    return cls;
}

class ComposerVC: UIViewController {
    static func instance(with hints: [Any]) -> ComposerVC {
        return also(ComposerVC()) { composer in
            hints.forEach { (hint) in
                let factory: VCFactory
                switch hint {
                case let hint as VCInitializer.Type: factory = { hint.instance() }
                case let hint as VCFactory:          factory = hint
                default: return
                }
                composer.addChild(also(factory()) { [weak composer] in
                    composer?.stack.addArrangedSubview($0.view)
                })
            }
        }
    }
    let _sv = UIScrollView()
    let _contentView = also(UIView()) { $0.backgroundColor = .white }
    let stack = also(UIStackView()) { $0.axis = .vertical }
    var sectionTypes: [ITZ.Type]? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(_sv)
        view.backgroundColor = .white
        _sv.translatesAutoresizingMaskIntoConstraints = false
        _sv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        _sv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        _sv.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        _sv.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        _sv.addSubview(_contentView)
        _contentView.translatesAutoresizingMaskIntoConstraints = false
        _contentView.topAnchor.constraint(equalTo: _sv.topAnchor).isActive = true
        _contentView.bottomAnchor.constraint(equalTo: _sv.bottomAnchor).isActive = true
        _contentView.leadingAnchor.constraint(equalTo: _sv.leadingAnchor).isActive = true
        _contentView.trailingAnchor.constraint(equalTo: _sv.trailingAnchor).isActive = true
        _contentView.widthAnchor.constraint(equalTo: _sv.widthAnchor).isActive = true
        let hAnchor = _contentView.heightAnchor.constraint(equalToConstant: 0)
        hAnchor.priority = .defaultLow
        hAnchor.isActive = true

        _contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.topAnchor.constraint(equalTo: _contentView.topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: _contentView.bottomAnchor).isActive = true
        stack.leadingAnchor.constraint(equalTo: _contentView.leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: _contentView.trailingAnchor).isActive = true

        sectionTypes?.forEach({ (type) in
            let vc = type.instance()
            addChild(vc)
            stack.addArrangedSubview(vc.view)
        })
        stack.addArrangedSubview(also(UIView()) { $0.backgroundColor = .white      })
    }
}
