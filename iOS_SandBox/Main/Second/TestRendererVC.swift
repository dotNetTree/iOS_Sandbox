//
//  TestRendererVC.swift
//  iOS_SandBox
//
//  Created by SeungChul Kang on 01/09/2019.
//  Copyright © 2019 BSide_Yoru_Study. All rights reserved.
//

import Foundation
import UIKit

class TestRendererVC: UIViewController, VCInitializer {
    static func instance() -> UIViewController {
        return UINib(nibName: "TestRendererVC", bundle: nil)
            .instantiate(withOwner: nil, options: nil)
            .first as! UIViewController
    }

    deinit {
        print("deinit TestRendererVC")
    }
    let pause = Looper.Pause()
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var containerH: NSLayoutConstraint!
    @IBOutlet weak var button: UIButton! {
        didSet {
            button.addAction { [weak self] _ in
                self?.pause.active.toggle()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let root = also(
            Renderer.Item(
                renderer: ViewRenderer(target: also(UIView()) {
                    $0.backgroundColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1.0)
                })
            )
        ) { item in
            item.style.placer = BlockPlacer
            item.style.width.value  = "auto"
            item.style.height.value = "auto"
            Watcher.who(self.view, pause: self.pause)
                .watch(\.bounds) { [weak item] (_, vals) in
                    item?.style.width?.value = Double(vals.1.size.width)
                    item?.reflow()
                }
        }

        let item0 = also(
            Renderer.Item(
                renderer: ViewRenderer(target: also(UIView()) {
                    $0.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
                })
            )
        ) {
            let placer = _GridPlacer.init(
                cols: 3, spacing: (v: 10, h: 20)
            )
            placer.padding = _GridPlacer.Padding(l: 20, t: 20, r: 20, b: 20)
            $0.style.placer = placer
            $0.style.width.value  = "match_parent"
            $0.style.height.value = "auto"
            after(delay: 5, closure: {
                placer.cols = 1
//                placer.padding = _GridPlacer.Padding(l: 20, t: 20, r: 20, b: 20)
                after(delay: 5, closure: {
                    placer.cols = 2
                    placer.padding = _GridPlacer.Padding()
                })
            })
        }
        let xibView1: TestXibView = UINib.view()!
        let xibView2: TestXibView = UINib.view()!
        let xibView3: TestXibView = UINib.view()!
        let item0_1 = also(
            Renderer.Item(
                renderer: ViewRenderer(target: also(xibView1) {
                    $0.backgroundColor = UIColor(red: 1, green: 0, blue: 1, alpha: 1.0)
                })
            )
        ) {
//            $0.style.width.value  = "auto"
//            $0.style.height.value = "auto"
            $0.style.backgroundColor.value = "#ffff00"
        }
        let item0_2 = also(
            Renderer.Item(
                renderer: ViewRenderer(target: also(xibView2) {
                    $0.backgroundColor = UIColor(red: 0, green: 1, blue: 1, alpha: 1.0)
                })
            )
        ) {
            _ = $0.style.width.value
//            $0.style.height.value = "auto"
        }

        let item0_3 = also(
            Renderer.Item(
                renderer: ViewRenderer(target: also(xibView3) {
                    $0.backgroundColor = UIColor(red: 0.3, green: 0.7, blue: 0.2, alpha: 1.0)
                })
            )
        ) {
            _ = $0.style.width.value
            //            $0.style.height.value = "auto"
        }

        //                    self?.containerH.constant = CGFloat(root.offset.h)
        //                    UIView.animate(withDuration: 15 * t / 1000) {
        //                        self?.parent?.view.layoutIfNeeded()
        //                    }


        root.add(item: item0)
//        Watcher.who(root.target()).watch(\.frame) { (_, vals) in
////            root.style.height.value = Double(vals.1.size.height)
//            root.reflow()
//        }
        Watcher.who(item0_1.target().subviews.first, pause: self.pause).watch(\.frame) { [weak self, weak item0_1, weak root] (_, vals) in
            UIView.animate(withDuration: 0.25) {
                item0_1?.style.height.value = Double(vals.1.size.height)
                item0_1?.reflow()
            }
            self?.containerH.constant = CGFloat(root?.offset.h ?? 0)
            UIView.animate(withDuration: 0.25) {
                self?.parent?.view.layoutIfNeeded()
            }
        }
        Watcher.who(item0_2.target().subviews.first, pause: self.pause).watch(\.frame) { [weak self, weak item0_2, weak root] (_, vals) in
            UIView.animate(withDuration: 0.25) {
                item0_2?.style.height.value = Double(vals.1.size.height)
                item0_2?.reflow()
            }
            self?.containerH.constant = CGFloat(root?.offset.h ?? 0)
            UIView.animate(withDuration: 0.25) {
                self?.parent?.view.layoutIfNeeded()
            }
        }

        Watcher.who(item0_3.target().subviews.first, pause: self.pause).watch(\.frame) { [weak self, weak item0_3, weak root] (_, vals) in
            UIView.animate(withDuration: 0.25) {
                item0_3?.style.height.value = Double(vals.1.size.height)
                item0_3?.reflow()
            }
            self?.containerH.constant = CGFloat(root?.offset.h ?? 0)
            UIView.animate(withDuration: 0.25) {
                self?.parent?.view.layoutIfNeeded()
            }
        }

        item0.add(item: item0_1)
        item0.add(item: item0_2)
        item0.add(item: item0_3)
        item0.reflow()
//        let item1 = also(
//            Renderer.Item(
//                renderer: ViewRenderer(target: also(UIView()) {
//                    $0.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1.0)
//                })
//            )
//        ) {
//            $0.style.width.value  = 200
//            $0.style.height.value = 200
//        }
//        root.addItem(item: item1)
        container.addSubview(root.target())
        root.reflow()

        looper.invoke { [weak self] (dsl) in
            var count = 0
            var toggle = false
            let t: Double = 30
            dsl.isInfinity = true
            dsl.block = { item in
                guard self != nil else { item.isStop = true; return }
                _ = root    // root hold...
                count += 1
                if count % 40 == 0 {
                    toggle.toggle()
//                    root.style.placer = toggle ? InlinePlacer : BlockPlacer
//                    item0.style.width.value = Int.random(in: 0...1) == 1 ? "match_parent" : "auto"
                    let idx1 = Int.random(in: 0...(data.count - 1))
                    let idx2 = { () -> Int in
                        var ret: Int = -1
                        repeat {
                            ret = Int.random(in: 0...(data.count - 1))
                        } while (idx1 == ret)
                        return ret
                    }()

//                    if let visibility = item0_2.style.visibility.value as? String {
//                        item0_2.style.visibility.value = visibility == Renderer.Visibility.VISIBLE
//                                                        ? Renderer.Visibility.GONE
//                                                        : Renderer.Visibility.VISIBLE
//                    }
                    xibView1.title.text = data[idx1]["title"]
                    xibView1.desc.text  = data[idx1]["desc"]
                    xibView2.title.text = data[idx2]["title"]
                    xibView2.desc.text  = data[idx2]["desc"]
                    xibView3.title.text = data[idx1]["title"]
                    xibView3.desc.text  = data[idx1]["desc"]
//                    item0_1.reflow()
//                    UIView.animate(withDuration: 15 * t / 1000) {
////                        item0_1.style.width.value  = Double.random(in: 0...300) + 30
////                        item0_1.style.height.value = Double.random(in: 0...300) + 30
//                        item0_1.style.backgroundColor.value = { () -> String in
//                            let r = String(Int.random(in: 0...155) + 100, radix: 16)
//                            let g = String(Int.random(in: 0...155) + 100, radix: 16)
//                            let b = String(Int.random(in: 0...155) + 100, radix: 16)
//                            return "#\(r)\(g)\(b)"
//                        }()
////                        item0_2.style.width.value  = Double.random(in: 0...300) + 30
////                        item0_2.style.height.value = Double.random(in: 0...300) + 30
//                        item0_2.style.backgroundColor.value = { () -> String in
//                            let r = String(Int.random(in: 0...155) + 100, radix: 16)
//                            let g = String(Int.random(in: 0...155) + 100, radix: 16)
//                            let b = String(Int.random(in: 0...155) + 100, radix: 16)
//                            return "#\(r)\(g)\(b)"
//                        }()
//                        item1.style.width.value  = Double.random(in: 0...200) + 50
//                        item1.style.height.value = Double.random(in: 0...200) + 50
//                        item0_1.reflow()

//                    }
//                    self?.containerH.constant = CGFloat(root.offset.h)
//                    UIView.animate(withDuration: 15 * t / 1000) {
//                        self?.parent?.view.layoutIfNeeded()
//                    }
                    count = 0
                }
            }

        }
    }
    

}

let data = [
    [
        "title": "그것: 두 번째 이야기",
        "desc": """
            27년마다 아이들이 사라지는 마을 데리, 또 다시 ‘그것’이 나타났다.
            27년 전, 가장 무서워하는 것의 모습으로 나타나 아이들을 잡아먹는 그것 페니와이즈에 맞섰던 ‘루저 클럽’ 친구들은 어른이 되어도 더 커져만 가는 그것의 공포를 끝내기 위해 피할 수 없는 마지막 대결에 나선다.
            """
    ],
    [
        "title": "유열의 음악앨범",
        "desc": """
            "오늘 기적이 일어났어요."
            1994년 가수 유열이 라디오 DJ를 처음 진행하던 날,
            엄마가 남겨준 빵집에서 일하던 미수(김고은)는 우연히 찾아 온 현우(정해인)를 만나
            설레는 감정을 느끼게 되지만 뜻하지 않은 사건으로 인해 연락이 끊기게 된다.

            "그때, 나는 네가 돌아오지 않을 거라고 생각했어. 그래도 기다렸는데…"
            다시 기적처럼 마주친 두 사람은 설렘과 애틋함 사이에서 마음을 키워 가지만 서로의 상황과 시간은 자꾸 어긋나기만 한다.
            계속되는 엇갈림 속에서도 라디오 ‘유열의 음악앨범’과 함께 우연과 필연을 반복하는 두 사람…

            함께 듣던 라디오처럼 그들은 서로의 주파수를 맞출 수 있을까?
            """
    ],
    [
        "title": "엑시트",
        "desc": """
            짠내 폭발 청년백수, 전대미문의 진짜 재난을 만나다!
            대학교 산악 동아리 에이스 출신이지만
            졸업 후 몇 년째 취업 실패로 눈칫밥만 먹는 용남은
            온 가족이 참석한 어머니의 칠순 잔치에서
            연회장 직원으로 취업한 동아리 후배 의주를 만난다
            어색한 재회도 잠시, 칠순 잔치가 무르익던 중
            의문의 연기가 빌딩에서 피어 오르며
            피할 새도 없이 순식간에 도심 전체는 유독가스로 뒤덮여 일대혼란에 휩싸이게 된다.
            용남과 의주는 산악 동아리 시절 쌓아 뒀던 모든 체력과 스킬을 동원해
            탈출을 향한 기지를 발휘하기 시작하는데…
            """
    ],
    [
        "title": "변신",
        "desc": """
            “어제 밤에는 아빠가 두 명이었어요”
            사람의 모습으로 변신하는 악마가 우리 가족 안에 숨어들면서
            기이하고 섬뜩한 사건들이 벌어진다
            서로 의심하고 증오하고 분노하는 가운데
            구마 사제인 삼촌 '중수'가 예고없이 찾아오는데…

            절대 믿지도 듣지도 마라
            """
    ],
    [
        "title": "분노의 질주: 홉스&쇼",
        "desc": """
            드디어 그들이 만났다!
            공식적으로만 세상을 4번 구한 ,, 베테랑 경찰 ‘루크 홉스’(드웨인 존슨)
            분노 조절 실패로 쫓겨난 전직 특수요원 ‘데카드 쇼’(제이슨 스타뎀)
            99.9% 완벽히 다른 두 남자는 전 세계를 위협하는 불가능한 미션을 해결하기 위해
            어쩔 수 없이 한 팀이 되고 마는데…
            """
    ]
]

