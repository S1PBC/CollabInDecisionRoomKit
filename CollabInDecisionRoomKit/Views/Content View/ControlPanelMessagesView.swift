//
//  ControlRoomMessagesView.swift
//
//  Created by Ella Isgar on 11/24/25.
//

//import SwiftUI
//
///// A view for the messages announced by the Control Panel.
//struct ControlPanelMessagesView: View {
//
//    var body: some View {
//
//        VStack(spacing: 0) {
//
//            Text("Control Room Messages")
//                .font(.largeTitle)
//                .padding()
//
//            ScrollView {
//
//                VStack(
//                    alignment: .leading,
//                    spacing: 5
//                ) {
//
//
//                }
//                .frame(
//                    maxWidth: .infinity,
//                    alignment: .leading
//                )
//
//            }
//            .padding()
//            .frame(
//                maxWidth: .infinity,
//                maxHeight: .infinity
//            )
//            .background {
//                RoundedRectangle(cornerSize: CGSize(width: 25, height: 25))
//                    .fill(Color.black.opacity(0.2))
//            }
//        }
//        .frame(
//            maxWidth: 1200,
//            maxHeight: 175
//        )
//
//    }
//
//}

// ControlPanelMessagesView.swift

import SwiftUI

struct ControlPanelMessagesView: View {
    @Environment(COR.self) var cor

    var body: some View {
        VStack(spacing: 0) {
            Text("Control Room Messages")
                .font(.largeTitle)
                .padding()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(cor.messages) { message in
                            ControlRoomMessageView(message)
                        }
                        // Invisible anchor at the bottom
                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onChange(of: cor.messages.count) {
                    // Auto-scroll to latest message
                    withAnimation {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                RoundedRectangle(cornerSize: CGSize(width: 25, height: 25))
                    .fill(Color.black.opacity(0.2))
            }
        }
        .frame(maxWidth: 1200, maxHeight: 175)
    }
}

struct ControlRoomMessageView: View {
    let message: CORMessage
    
    init(_ message: CORMessage) {
        self.message = message
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(message.timestamp.formatted(date: .omitted, time: .standard))
                .font(.caption)
                .foregroundStyle(.gray)
            Text(message.text)
                .fontWeight(.bold)
                .foregroundStyle(.green)
        }
    }
}
