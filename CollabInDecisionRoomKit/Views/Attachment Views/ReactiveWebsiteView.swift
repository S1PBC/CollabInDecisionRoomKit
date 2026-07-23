//
//  ReactiveWebsiteView.swift
//  Rooms
//
//  Created by Ella Isgar on 2/25/26.
//

import SwiftUI
import WebKit

struct ReactiveWebsiteView: View {

    // Each panel's web attachment listens only to its own control button via the linkedControlID

    let url: String
    let bindings: [RoomBinding]

    @State private var refreshToken = UUID()

    var body: some View {
        
        WebsiteView(url: url)
            .id(refreshToken)  // forcing a rebuild reloads the WKWebView
            .onReceive(
                NotificationCenter.default.publisher(for: .controlStateUpdated)
            ) { notification in
                guard
                    let update = notification.object as? RoomControlStateUpdate,
                    let binding = bindings.first(where: {
                        $0.control == update.source
                    }),
                    case .toggle(let value) = update.state
                else { return }

                // binding.intendedAction tells us what case to produce
                switch binding.intendedAction {
                case .refresh:
                    refreshToken = UUID()
                default:
                    break
                }
            }
    }
}

struct WebsiteView: UIViewRepresentable{
    
    var url:String
    
    
    func makeUIView(context: Context) -> some UIView {
        guard let url = URL(string: url) else {
            return WKWebView()
        }
        let webview = WKWebView()
        webview.pageZoom = 1.5
        webview.load(URLRequest(url: url))
        return webview
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

///// A view to display a website. This view allows a user's input.
//struct WebsiteView: UIViewRepresentable {
//    
//    /// The web address to load onto the view.
//    let urlString: String
//
//    /// Creates the web view.
//    func makeUIView(context: Context) -> WKWebView {
//        let webview = WKWebView()
////        webview.isOpaque = false
////        webview.backgroundColor = .clear
//        webview.scrollView.backgroundColor = .clear
//        // TODO: pageZoom needs to be configurable from room creation.
//        webview.pageZoom = 1.5
//        guard let url = URL(string: urlString) else { return webview }
//        webview.load(URLRequest(url: url))
//        return webview
//    }
//
//    /// Nada to update.
//    func updateUIView(_ uiView: WKWebView, context: Context) {}
//}
