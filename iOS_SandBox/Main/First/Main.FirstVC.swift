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

//            Funnel()
//                .next(body: { (fulfill) in
//                    print("1 - 1 action")
//                    after(delay: 2) {
//                        fulfill(Funnel.Completion {
//                            print("1 - 1 end")
//                        })
//                    }
//                })
//                .phase { () -> Funnel in
//                    Funnel().next { (fulfill) in
//                        print("2 - 1 action")
//                        after(delay: 2) {
//                            fulfill(Funnel.Completion {
//                                print("2 - 1 end")
//                            })
//                        }
//                    }
//                    .next { (fulfill) in
//                        print("2 - 2 action")
//                        after(delay: 10) {
//                            fulfill(Funnel.Completion {
//                                print("2 - 2 end")
//                            })
//                        }
//                    }
//                }
//                .phase { () -> Funnel in
//                    Funnel().next { (fulfill) in
//                        print("3 - 1 action")
//                        after(delay: 2) {
//                            fulfill(Funnel.Completion {
//                                print("3 - 1 end")
//                            })
//                        }
//                    }
//                    .next { (fulfill) in
//                        print("3 - 2 action")
//                        after(delay: 10) {
//                            fulfill(Funnel.Completion {
//                                print("3 - 2 end")
//                            })
//                        }
//                    }
//                }
//                .next(body: { (fulfill) in
//                    print("1 - 2 action")
//                    after(delay: 2) {
//                        fulfill(Funnel.Completion {
//                            print("1 - 2 end")
//                        })
//                    }
//                })
//                .start()
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
