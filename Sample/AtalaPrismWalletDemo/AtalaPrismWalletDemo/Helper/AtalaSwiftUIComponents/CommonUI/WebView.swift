import SwiftUI
import UIKit
import WebKit

struct WebView: UIViewRepresentable {
    enum Source {
        case url(URL)
        case html(String)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var view: WKWebView? {
            didSet {
                view?.navigationDelegate = self
            }
        }

        var didLoad = false

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            webView.reload()
        }
    }

    let source: Source
    @Environment(\.presentationMode) var presentationMode

    init(source: Source) {
        self.source = source
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        guard let view = context.coordinator.view else {
            switch source {
            case let .url(url):
                let view = WKWebView()
                context.coordinator.view = view
                let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
                view.load(request)
                return view
            case let .html(html):
                let view = ResizableWebView()
                context.coordinator.view = view
                view.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
                return view
            }
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard
            presentationMode.wrappedValue.isPresented,
            !context.coordinator.didLoad,
            let view = context.coordinator.view
        else { return }
        switch source {
        case let .url(url):
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            view.load(request)
        case let .html(html):
            DispatchQueue.main.async {
                view.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
            }
        }
    }
}

class ResizableWebView: WKWebView {
    init() {
        let configuration = WKWebViewConfiguration()
        super.init(frame: .zero, configuration: configuration)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return scrollView.contentSize
    }
}
