//
//  HtmlView.swift
//  V2er
//
//  Created by ghui on 2021/11/1.
//  Copyright © 2021 lessmore.io. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import WebKit

// MARK: - WebViewHandlerDelegate
// For printing values received from web app
protocol WebViewHandlerDelegate {
    func receivedJsonValueFromWebView(value: [String: Any?])
    func receivedStringValueFromWebView(value: String)
}

struct HtmlView: View {
    let html: String?
    @State var height: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            Webview(html: html, height: $height)
        }
        .frame(height: height)
        .debug()
    }
}

fileprivate struct Webview: UIViewRepresentable, WebViewHandlerDelegate {
    let html: String?
    @Binding var height: CGFloat

    // Make a coordinator to co-ordinate with WKWebView's default delegate functions
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> WKWebView {
        // Enable javascript in WKWebView
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        //        preferences.allowsContentJavaScript = true
        let wkpref = WKWebpagePreferences()
        wkpref.allowsContentJavaScript = true

//        webView.configuration.preferences.javaScriptEnabled = true

        let configuration = WKWebViewConfiguration()
        // Here "iOSNative" is our delegate name that we pushed to the website that is being loaded
        configuration.userContentController.add(self.makeCoordinator(), name: "iOSNative")
        configuration.preferences = preferences

        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.isScrollEnabled = true
        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        var content = Bundle.readString(name: "v2er", type: "html")
        // TODO: dark mode
        let isDark = false
        let fontSize = 16
        let params = "\(isDark), \(fontSize)"
        content = content?.replace(segs: "{injecttedContent}", with: html ?? .empty)
                          .replace(segs: "{INJECT_PARAMS}", with: params)
        let baseUrl = Bundle.main.bundleURL
        webView.loadHTMLString(content ?? .empty, baseURL: baseUrl)
    }

    func receivedJsonValueFromWebView(value: [String : Any?]) {
        print("JSON value received from web is: \(value)")
    }

    func receivedStringValueFromWebView(value: String) {
        print("String value received from web is: \(value)")
    }

    class Coordinator : NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: Webview
        var delegate: WebViewHandlerDelegate?

        init(_ webview: Webview) {
            self.parent = webview
            self.delegate = parent
        }

        func userContentController(_ userContentController: WKUserContentController,
                                   didReceive message: WKScriptMessage) {
            // Make sure that your passed delegate is called
            if message.name == "iOSNative" {
                if let body = message.body as? [String: Any?] {
                    delegate?.receivedJsonValueFromWebView(value: body)
                } else if let body = message.body as? String {
                    delegate?.receivedStringValueFromWebView(value: body)
                }
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            injectImgClicker(webView)
            measureHeightOfHtml(webView)
        }

        private func injectImgClicker(_ webview: WKWebView) {
            let javascriptFunction = "addClickToImg()"
            webview.evaluateJavaScript(javascriptFunction) { (response, error) in
                if let error = error {
                    print("Error calling javascript:valueGotFromIOS()")
                    print(error.localizedDescription)
                } else {
                    print("Called javascript:valueGotFromIOS()")
                }
            }
        }

        private func measureHeightOfHtml(_ webview: WKWebView) {
            webview.evaluateJavaScript("document.documentElement.scrollHeight") { (height, error) in
                DispatchQueue.main.async {
                    self.parent.height = height as! CGFloat
                }
            }
        }

    }

}