//
//  ContentView.swift
//  CollabInDecisionRoomKit
//
//  Created by Logan Lechuga on 7/21/26.
//

import SwiftUI
import RealityKit

struct ContentView: View {

    var body: some View {
        VStack {
            ToggleImmersiveSpaceButton()
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
