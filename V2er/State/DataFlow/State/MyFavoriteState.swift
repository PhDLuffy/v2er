//
//  MyFavoriteState.swift
//  V2er
//
//  Created by ghui on 2021/10/6.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import SwiftSoup

struct MyFavoriteState: FluxState {
    var feedState = FeedState()
    var nodeState = NodeState()

    struct FeedState {
        var updatable = UpdatableState()
        var model: Model?

        struct Model: BaseModel {
            var totalPage: Int = 0
            var items: [Item] = []

            struct Item: FeedItemInfo {
                var id: String
                var avatar: String?
                var userName: String?
                var replyUpdate: String?
                var title: String?
                var replyNum: String? = 0.string
                var tagName: String?
                var tagId: String?

                init(id: String) {
                    self.id = id
                }

                init?(from html: Element?) {
                    guard let root = html else { return nil }
                    id = parseFeedId(root.pick("span.item_title a[href^=/t/]", .href))
                    avatar = root.pick("img.avatar", .src)
                    userName = root.pick("strong a[href^=/member/]")
                    title = root.pick("span.item_title a[href^=/t/]")
                    replyNum = root.pick("a[class^=count_]")
                    tagName = root.pick("a.node")
                    tagId = root.pick("a.node", .href)
                        .segment(separatedBy: "/")
                    let timeReplier = root.pick("span.topic_info")
                    replyUpdate = timeReplier.segment(separatedBy: "•", at: 2)
                    let replier = timeReplier.segment(separatedBy: "•", at: 3)
                        .segment(separatedBy: " ")
                    replyUpdate?.append("\(replier) 回复了")
                }
            }

            init?(from html: Element?) {
                guard let root = html?.pickOne("div#Wrapper") else { return nil }
                let lastNormalpage = root.pick("div.box a.page_normal", at: .last).int
                let currentPage = root.pick("div.box span.page_current").int
                totalPage = max(lastNormalpage, currentPage)
                let es = root.pickAll("div.cell.item")
                for e in es {
                    guard let item = Item(from: e) else { continue }
                    items.append(item)
                }
            }
        }

    }

    struct NodeState {
        var updatable = UpdatableState()
        var model: Model?

        struct Model: BaseModel {
            var items: [Item] = []

            struct Item: HtmlItemModel {
                var id: String
                var img: String
                var name: String
                var topicNum: String

                init?(from html: Element?) {
                    guard let root = html else { return nil }
                    id = root.value(.href)
                        .segment(separatedBy: "/")
                    img = parseAvatar(root.pick("img", .src))
                    name = root.pick("span.fav-node-name", .ownText)
                    topicNum = root.pick("span.fade.f12")
                }
            }

            init?(from html: Element?) {
                guard let root = html?.pickOne("div#my-nodes") else { return nil }
                let es = root.pickAll("a.fav-node")
                for e in es {
                    guard let item = Item(from: e) else { continue }
                    items.append(item)
                }
            }
        }
    }
}


