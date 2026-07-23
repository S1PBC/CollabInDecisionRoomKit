//
//  ExitAppButton.swift
//
//  Created by Ella Isgar on 12/1/25.
//

import SwiftUI

/// The "Exit App" button for the ContentView. This button's action is equivalent to force-quitting the app.
struct ExitAppButton: View {

    var body: some View {
        
        Button(
            action: {
                exit(0)
            },
            label: {
                Text("Exit App")
                    .font(.title2)
            }
        )
        .buttonStyle(.borderedProminent)
        .tint(Color.red)

    }

}
