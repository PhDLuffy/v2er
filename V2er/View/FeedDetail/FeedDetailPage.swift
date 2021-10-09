//
//  NewsDetailPage.swift
//  V2er
//
//  Created by Seth on 2021/7/6.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import SwiftUI

struct FeedDetailPage: StateView, KeyboardReadable, InstanceIdentifiable {

    @Environment(\.isPresented) private var isPresented
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var store: Store

    var bindingState: Binding<FeedDetailState> {
        if store.appState.feedDetailStates[instanceId] == nil {
            store.appState.feedDetailStates[instanceId] = FeedDetailState()
        }
        return $store.appState.feedDetailStates[instanceId]
    }

    var instanceId: String {
        self.id
    }
    @State var hideTitleViews = true
    @State var replyContent = ""
    @State var isKeyboardVisiable = false
    @FocusState private var replyIsFocused: Bool
    var initData: FeedInfo.Item? = nil
    var id: String

    init(id: String) {
        self.id = id
    }

    init(initData: FeedInfo.Item?) {
        self.initData = initData
        self.id = self.initData!.id
    }

    private var hasReplyContent: Bool {
        !replyContent.isEmpty
    }
    
    var body: some View {
        VStack (spacing: 0) {
            LazyVStack(spacing: 0) {
                AuthorInfoView(initData: initData, data: state.model.headerInfo)
                NewsContentView(state.model.contentInfo)
                    .padding(.horizontal, 10)
                    .hide(state.showProgressView)
                actionItems
                    .hide(state.showProgressView)
                replayListView
                    .padding(.top, 8)
                    .hide(state.showProgressView)
            }
            .background(state.showProgressView ? .clear : Color.pageLight)
            .updatable(autoRefresh: state.showProgressView, hasMoreData: state.hasMoreData) {
                await run(action: FeedDetailActions.FetchData.Start(id: instanceId, feedId: initData?.id))
            } loadMore: {
                await run(action: FeedDetailActions.LoadMore.Start(id: instanceId, feedId: initData?.id, willLoadPage: state.willLoadPage))
            } onScroll: { scrollY in
                withAnimation {
                    hideTitleViews = !(scrollY <= -100)
                }
                replyIsFocused = false
            }
            replyBar
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            navBar
        }
        .ignoresSafeArea(.container)
        .navigationBarHidden(true)
        .onTapGesture {
            replyIsFocused = false
        }
        .onAppear {
            dispatch(action: FeedDetailActions.FetchData.Start(id: instanceId, feedId: initData?.id, autoLoad: !state.hasLoadedOnce))
        }
        .onDisappear {
            if !isPresented {
                log("onPageClosed----->")
//                dispatch(action: InstanceDestoryAction(target: .feeddetail, id: instanceId))
            }
        }
    }
    
    @ViewBuilder
    private var actionItems: some View {
        VStack {
            HStack(spacing: 16) {
                // 收藏，忽略，感谢，举报, up, down
                
                Button("收藏") {
                    
                }
                Button("感谢") {
                    
                }
                
                Button("忽略") {
                    
                }
                
                Button("举报") {
                    
                }
                
                Spacer()
            }
            .padding(.top, 4)
            .padding(.horizontal, 16)
            .foregroundColor(.black)
            .font(.body)
            Divider()
        }
    }
    
    
    private var replyBar: some View {
        VStack(spacing: 0) {
            Divider()
            VStack(spacing: 0) {
                HStack(alignment: .bottom, spacing: 0) {
                    MultilineTextField("发表回复", text: $replyContent)
                        .debug()
                        .onReceive(keyboardPublisher) { isKeyboardVisiable in
                            self.isKeyboardVisiable = isKeyboardVisiable
                        }
                        .focused($replyIsFocused)

                    Button(action: {
                        // Do submit
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title.weight(.regular))
                            .foregroundColor(Color.bodyText.opacity(hasReplyContent ? 1.0 : 0.6))
                            .padding(.trailing, 6)
                            .padding(.vertical, 3)
                    }
                    .disabled(!hasReplyContent)
                }
                .background(Color.lightGray)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                
                if isKeyboardVisiable {
                    actionBar
                        .transition(.opacity)
                }
            }
            .padding(.bottom, isKeyboardVisiable ? 0 : topSafeAreaInset().bottom * 0.9)
            .padding(.top, 10)
            .padding(.horizontal, 10)
            .background(Color.white)
        }
    }
    
    @ViewBuilder
    private var actionBar: some View {
        HStack (spacing: 10) {
            Image(systemName: "photo.on.rectangle")
                .font(.title2.weight(.regular))
            Image(systemName: "face.smiling")
                .font(.title2.weight(.regular))
            Spacer()
        }
        .greedyWidth()
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var navBar: some View  {
        NavbarHostView(paddingH: 0) {
            HStack(alignment: .center, spacing: 4) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.title2.weight(.regular))
                        .padding(.leading, 8)
                        .padding(.vertical, 10)
                        .foregroundColor(.tintColor)
                }
                Group {
                    // FIXME: use real value
                    NavigationLink(destination: UserDetailPage(userId: initData?.id)) {
                        AvatarView(url: state.model.headerInfo?.avatar ?? .empty, size: 32)
                    }
                    VStack(alignment: .leading) {
                        Text("话题")
                            .font(.headline)
                        Text(state.model.headerInfo?.title ?? .empty)
                            .font(.subheadline)
                            .greedyWidth(.leading)
                    }
                    .lineLimit(1)
                }
                .opacity(hideTitleViews ? 0.0 : 1.0)
                Button {
                    // Show more actions
                } label: {
                    Image(systemName: "ellipsis")
                        .padding(8)
                        .font(.title3.weight(.regular))
                        .foregroundColor(.tintColor)
                }
            }
            .padding(.vertical, 5)
            .padding(.trailing, 5)
            .overlay {
                Text("话题")
                    .font(.headline)
                    .opacity(hideTitleViews ? 1.0 : 0.0)
            }
            .greedyWidth()
        }
        .visualBlur()
    }
    
    @ViewBuilder
    private var replayListView: some View {
        //        LazyVStack(spacing: 0) {
        ForEach(state.model.replyInfo.items) { item in
            ReplyItemView(info: item)
        }
        //        }
    }
    
}

struct NewsDetailPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FeedDetailPage(id: .empty)
        }
    }
}
