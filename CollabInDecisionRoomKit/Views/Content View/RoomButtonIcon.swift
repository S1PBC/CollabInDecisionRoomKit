//
//  RoomButtonIcon.swift
//
//  Created by Ella Isgar on 12/4/25.
//

import SwiftUI

enum RoomButtonIcon: Codable {
    case missing
    case videosPubliclyAvailable
    case sealOfMDA_UNCLASS
    case circularRoom
    case helixRoom

    @ViewBuilder var view: some View {

        VStack(spacing: 0) {
            switch self {

            case .missing:
                VStack(spacing: 2) {
                    Image(systemName: "questionmark.circle.dashed")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .padding(10)

            case .videosPubliclyAvailable:
                VStack(spacing: 2) {
                    Text("Videos")
                    Text("Publicly")
                    Text("Available")
                }
                .font(.caption)

            case .sealOfMDA_UNCLASS:
                VStack(spacing: 0) {
                    Image("SealOfMDA")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40)

                    Spacer()

                    Text("UNCLASS")
                        .foregroundColor(.green)
                }

            case .circularRoom:
                VStack(spacing: 0) {
                    Image("CircularRoomGeometry1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                }

            case .helixRoom:
                VStack(spacing: 0) {
                    Image("HelixRoomGeometry1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                }
            }

        }
        .frame(width: 80, height: 70)

    }
}

// MARK: Generic Rooms demonstrating each available RoomButtonIcon
let roomsDemonstratingEveryRoomButtonIcon = [
    makeGenericRoom(
        n: 1,
        prettyName: "Using .circularRoom",
        roomButtonIcon: RoomButtonIcon.circularRoom
    ),

    makeGenericRoom(
        n: 2,
        prettyName: "Using .helixRoom",
        roomButtonIcon: RoomButtonIcon.helixRoom
    ),

    makeGenericRoom(
        n: 3,
        prettyName: "Using .missing",
        roomButtonIcon: RoomButtonIcon.missing
    ),

    makeGenericRoom(
        n: 4,
        prettyName: "Using .sealOfMDA_UNCLASS",
        roomButtonIcon: RoomButtonIcon.sealOfMDA_UNCLASS
    ),

    makeGenericRoom(
        n: 5,
        prettyName: "Using .videosPubliclyAvailable",
        roomButtonIcon: RoomButtonIcon.videosPubliclyAvailable
    ),
]
