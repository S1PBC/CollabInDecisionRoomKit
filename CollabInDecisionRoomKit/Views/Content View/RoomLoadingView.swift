//
//  RoomLoadingView.swift
//
//  Created by Ella Isgar on 12/22/25.
//

import SwiftUI

// TODO: Make this view actually appear as a sheet ontop of the ContentView.

/// A view of a room-is-loading notice for the pop-up sheet of the ContentView.
struct RoomLoadingView: View {

    var body: some View {

        VStack {

            Text("Room is loading...")
                .font(.title)

            ProgressView()
                .scaleEffect(1.5)

        }
        .font(.title)

    }

}
