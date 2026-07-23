//
//  Example.swift
//  BREVA
//
//  Created by AidanCarrier on 12/11/25.
//

import SwiftUI
import RealityKit

struct ExampleTerminalViewContainer: View {
    @Environment(AppLogic.self) var appLogic
    
    @State private var visibility: NavigationSplitViewVisibility = .all
    var  body : some View {
        VStack{
            NavigationSplitView(columnVisibility: $visibility) {
                List {
//                    NavigationLink(
//                        "Logger",
//                        destination: TerminalView(appLogic: appLogic)
//                    )
                }
            } detail: {
                ContentUnavailableView(
                    "Select an element from the sidebar",
                    systemImage: "doc.text.image.fill"
                )
            }.padding(10)
            
            //  ToggleImmersiveSpaceButton()
        }
    }
}
