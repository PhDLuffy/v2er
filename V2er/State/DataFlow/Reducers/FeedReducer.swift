//
//  FeedReducer.swift
//  FeedReducer
//
//  Created by ghui on 2021/8/10.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation

func feedStateReducer(_ state: FeedState, _ action: Action) -> (FeedState, Action?) {
    var state = state
    var followingAction: Action?
    if action is AsyncAction || action is AwaitAction { followingAction = action }
    switch action {
        case let action as FeedActions.FetchData.Start:
            guard !state.refreshing else { break }
            state.autoLoad = action.autoStart
            state.refreshing = true
        case let action as FeedActions.FetchData.Done:
            state.refreshing = false
            state.autoLoad = false
            if case let .success(newsInfo) = action.result {
                state.newsInfo = newsInfo ?? FeedInfo()
                state.willLoadPage = 1
            } else {
                // Loaded failed
            }
        case let action as FeedActions.LoadMore.Start:
            guard !state.refreshing else { break }
            guard !state.loadingMore else { break }
            state.loadingMore = true
            break
        case let action as FeedActions.LoadMore.Done:
            state.loadingMore = false
            state.hasMoreData = true // todo check vary tabs
            if case let .success(newsInfo) = action.result {
                state.newsInfo.append(feedInfo: newsInfo!)
                state.willLoadPage += 1
            } else {
                // failed
            }
            break
        default:
            break
    }
    return (state, followingAction)
}