//
//  Endpoint.swift
//  Endpoint
//
//  Created by ghui on 2021/8/14.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

enum Endpoint {
    enum ResourceType {
        case html
        case json
    }

    case tab, recent, explore
    case signin, topic(topicId: String), notifications
    case myFollowing, myTopics, myNodes, nodesNav
    case nodeListDetail(nodeName: String)
    case userPage(userName: String), createTopic
    case appendTopic(id: String), thanksReply(id: String)
    case thanksAuthor(id: String), starTopic(id: String)
    case unStarTopic(id: String), ignoreTopic(id: String)
    case ignoreReply(id: String), ignoreNode(id: String)
    case unIgnoreNode(id: String), upTopic(id: String), downTopic(id: String)
    case replyTopic(id: String), blockUser(id: String)
    case followUser(id: String), starNode(id: String), dailyMission
    case checkin, twoFA, downMyTopic(id: String), pinTopic(id: String)

    func path() -> String {
        return info().path
    }

    func type() -> ResourceType {
        return info().type
    }

    func ua() -> UA {
        return info().ua
    }

    typealias Info = (path: String, type: ResourceType, ua: UA)

    private func info() -> Info {
        var info: Info = ("", .html, .wap)
        switch self {
            case .tab:
                info.path = "/"
            case .recent:
                info.path = "/recent"
            case .explore:
                info.path = "/"
                info.ua = .web
            case .signin:
                info.path = "/signin"
            case let .topic(id):
                info.path = "/t\(id)"
            case .notifications:
                info.path = "/notifications"
            case .myFollowing:
                info.path = "/my/following"
            case .myTopics:
                info.path = "/my/topics"
            case .myNodes:
                info.path = "/my/nodes"
            case .nodesNav:
                info.path = "/"
            case let .nodeListDetail(nodeName):
                info.path = "/go/\(nodeName)"
            case let .userPage(userName):
                info.path = "/member/\(userName)"
            case .createTopic:
                info.path = "/new"
            case let .appendTopic(id):
                info.path = "/append/topic/\(id)"
            case let .thanksReply(id):
                info.path = "/thank/reply/\(id)"
            case let .thanksAuthor(id):
                info.path = "/thank/topic/\(id)"
            case let .starTopic(id):
                info.path = "/favorite/topic/\(id)"
            case let .unStarTopic(id):
                info.path = "/unfavorite/topic/\(id)"
            case let .ignoreTopic(id):
                info.path = "/ignore/topic/\(id)"
            case let .ignoreReply(id):
                info.path = "/ignore/reply/\(id)"
            case let .ignoreNode(id):
                info.path = "/settings/ignore/node/\(id)"
            case let .unIgnoreNode(id):
                info.path = "/settings/unignore/node/\(id)"
            case let .upTopic(id):
                info.path = "/up/topic/\(id)"
            case let .downTopic(id):
                info.path = "/down/topic/\(id)"
            case let .replyTopic(id):
                info.path = "/t/\(id)"
            case let .blockUser(id):
                info.path = "/block/\(id)"
            case let .followUser(id):
                info.path = "/follow/\(id)"
            case let .starNode(id):
                info.path = "/favorite/node/\(id)"
            case .dailyMission:
                info.path = "/mission/daily"
            case .checkin:
                info.path = "/mission/daily/redeem"
            case .twoFA:
                info.path = "/2fa?next=/mission/daily"
            case let .downMyTopic(id):
                info.path = "/fade/topic/\(id)"
            case let .pinTopic(id):
                info.path = "/sticky/topic/\(id)"
        }
        return info
    }

}