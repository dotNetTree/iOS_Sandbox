//
//  Main.FirstVC.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 07/04/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

enum MainPackage {
    typealias VC = MainFirstVC
    @discardableResult
    static func factory(vc: VC) -> VC? {
        vc.model    = MainPackage.PersonModel(observer: vc)
//        vc.resolver = Resolver(storage: vc.model)
        return vc
    }
}

class MainFirstVC: UIViewController, ThrottleObserver {
    @IBOutlet weak var container: UIStackView!

    let section1 = PaddingView<VSectionView<MainFirstProfileTitle2View, MainFirstProfileContentView, MainFirstProfileBottomView>>()
    let section2 = PaddingView<VSectionView<MainFirstProfileTitle2View, MainFirstProfileContentView, MainFirstProfileBottomView>>()

    let section3 = PaddingView<VSectionView<MainFirstProfileTitle2View, MainFirstProfileContentView, MainFirstProfileBottomView>>()
    let section4 = PaddingView<VSectionView<MainFirstProfileTitle2View, MainFirstProfileContentView, MainFirstProfileBottomView>>()
    let renderder = ViewWrapper<MainFirstProfileTitleView, ViewState<Title>>()
    var model: FirstBusinessLogic!
//    var resolver: Resolver<FirstEntityCollection, MainPackage.At>!
//    let looper = Looper.Looper()

    override func viewDidLoad() {
        super.viewDidLoad()
        MainPackage.factory(vc: self)

        section1.content.body.click = { [weak self] add in
            self?.model.age(add: add)
        }
        var pause = false
        section1.content.tail.click = {
            switch !pause {
            case true: looper.pause()
            default:   looper.resume()
            }
            pause = !pause
//            print("next page gogogo...")
        }

//        container.addSubview(renderder.view)
        container.addArrangedSubview(section1)
//        container.addArrangedSubview(section2)
//        container.addArrangedSubview(section3)
//        container.addArrangedSubview(section4)
        model.throttle(open: true)
        model.throttle(open: false)

        after { [weak self] in

            Sieve()
                .async { (sync) in
                    print("1 - 1 action")
                    print("1 - 1 acting (3sec)")
                    after(delay: 3) {
                        print("1 - 1 finished")
                        sync({ print("1 - 1 fulfilled") })
                    }
                }
                .sync { print("1 - 2 fulfilled")  }
                .pause(delay: 10) { print("paused 10 sec...") }
                .bundle {
                    Sieve().async { (sync) in
                        print("2 - 1 action")
                        print("2 - 1 acting (4sec)")
                        after(delay: 4) {
                            print("2 - 1 finished")
                            sync({ print("2 - 1 fulfilled") })
                        }
                    }
                    .bundle {
                        Sieve().async { (sync) in
                            print("2 - 1 - 1 action")
                            print("2 - 1 - 1 acting (2sec)")
                            after(delay: 2) {
                                print("2 - 1 - 1 finished")
                                sync({ print("2 - 1 - 1 fulfilled") })
                            }
                        }
                    }
                    .async { (sync) in
                        print("2 - 2 action")
                        print("2 - 2 acting (2sec)")
                        after(delay: 2) {
                            print("2 - 2 finished")
                            sync({ print("2 - 2 fulfilled") })
                        }
                    }
                    .sync { print("2 - 3 fulfilled")  }
                }
                .bundle {
                    Sieve().async { (sync) in
                        print("3 - 1 action")
                        print("3 - 1 acting (2sec)")
                        after(delay: 2) {
                            print("3 - 1 finished")
                            sync({ print("3 - 1 fulfilled") })
                        }
                    }
                    .sync { print("3 - 2 sync") }
                    .async { (sync) in
                        print("3 - 3 action")
                        print("3 - 3 acting (2sec)")
                        after(delay: 10) {
                            print("3 - 3 finished")
                            sync({ print("3 - 3 fulfilled") })
                        }
                    }
                }
                .async { (sync) in
                    print("1 - 3 action")
                    print("1 - 3 acting (2sec)")
                    after(delay: 2) {
                        print("1 - 3 finished")
                        sync({ print("1 - 3 fulfilled") })
                    }
                }
                .sync { print("1 - 4 fulfilled") }
                .start()
            let composed: ComposerVC

            let isATest = true
            switch isATest {
            case true:      // A Test
                composed = ComposerVC.instance(with: [
                    TestRendererVC.self,
                    TestANaviVC.self,
                    { TestInformationVC.instance() },
                    { TestANaviVC.instance() },
                    TestInformationVC.self
                ])
            case false:     // B Test
                composed = ComposerVC.instance(with: [
                    { TestBNaviVC.instance() },
                    { TestInformationVC.instance() }
                ])
            }

            self?.navigationController?.pushViewController(composed, animated: true)
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        model.throttle(open: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        model.throttle(open: false)
    }

    func updated() {
        section1.set(with: MainPackage.MainSection().run(ec: model))
        looper.invoke { [weak section1] dsl in
            dsl.block = { _ in section1?.render() }
        }.next { _ in
            print("마지막으로 한번 출력!!!")
            print("마지막으로 한번 출력!!!")
            print("마지막으로 한번 출력!!!")
        }
    }
}
