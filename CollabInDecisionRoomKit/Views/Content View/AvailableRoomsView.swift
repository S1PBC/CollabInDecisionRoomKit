//
//  AvailableRoomsView.swift
//
//  Created by Ella Isgar on 11/24/25.
//

import SwiftUI

/// A view of the rooms currently available for viewing in the app. Each room is represented by their ``RoomButton``.
struct AvailableRoomsView: View {

    @Environment(COR.self) private var cor

    var body: some View {

        VStack(spacing: 0) {

            Text("Available Rooms")
                .font(.largeTitle)
                .padding()

            ScrollView {

                VStack {

                    Spacer()

                    ForEach(cor.getRooms().sorted(by: { $0.index < $1.index })) { i in
                        cor.createRoomButton(for: i.id)

                        Spacer()
                    }

                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
            }
            .disabled(cor.anyRoomIsLoading)
            .padding()
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .background {
                RoundedRectangle(cornerSize: CGSize(width: 25, height: 25))
                    .fill(Color.black.opacity(0.2))
            }

        }
        .frame(
            maxWidth: 550,
            maxHeight: 350
        )

    }

}
