//
//  ContentView.swift
//
//  Created by Luis Perez-Breva on 2/13/24.
//

import SwiftUI

struct ContentView: View {

    @Environment(AppLogic.self) var app
    @Environment(COR.self) var cor

    var body: some View {

        ZStack {
            BackgroundImageView()

            VStack {

                Spacer()

                // Row 1 - The title
                TitleView()

                // Row 2 - Available Rooms & room-specific Control Panel
                HStack(
                    spacing: 100
                ) {

                    AvailableRoomsView()

                    ControlPanelView()

                }
                .padding()

                // Row 3 - Control Panel's Messages
                ControlPanelMessagesView()

                // Row 4 - SharePlay & Exit Buttons
                HStack {
                    SharePlayButton()
                    ExitAppButton()
                }
                .padding()

                Spacer()

                // Row 5 - Footnote ("Patent Pending...")
                FootnoteView()

            }

        }
        .frame(width: 1300, height: 900)
        .sheet(
            isPresented: Binding<Bool>(
                get: { cor.anyRoomIsLoading },
                set: { cor.anyRoomIsLoading = $0 }
            )
        ) {
            RoomLoadingView()
        }

    }

}

////
////  ContentView.swift
////
////  Created by Ella Isgar on 2/25/26.
////
//
//import SwiftUI
//
//struct ContentView: View {
//
//    @Environment(AppLogic.self) var app
//    @Environment(COR.self) var cor
//
//    var body: some View {
//
//        ZStack {
//            BackgroundImageView()
//            
//            VStack {
//
//                Spacer()
//
//                // Row 1 - The title
//                TitleView()
//                    .border(.green, width: 2)
//
//                // Row 2 - Available Rooms & room-specific Control Panel
//                HStack(
//                    spacing: 100
//                ) {
//
//                    //                    AvailableRoomsView()
//                    //                        .border(.cyan, width: 2)
//                    //
//                    //                        cor.createRoomButton(for: "myPolygonRoom")
//                    //                            .border(.cyan, width: 2)
//                    RoomButton(
//                        roomID: "myPolygonRoom",
//                        roomButtonIcon: .circularRoom,
//                        prettyName: "My Polygon Room"
//                    )
//
//                    //                    Text("Place holder for availble rooms")
//                    //                        .border(.cyan, width: 2)
//
//                    //                    ControlPanelView()
//                    //                        .border(.yellow, width: 2)
//
//                    Text("Place holder for control panel view")
//                        .border(.yellow, width: 2)
//
//                }
//                .padding()
//
//                // Row 3 - Control Panel's Messages
//                //                ControlPanelMessagesView()
//                //                    .border(.red, width: 2)
//
//                Text("Place holder for control panel messages")
//                    .border(.cyan, width: 2)
//
//                // Row 4 - SharePlay & Exit Buttons
//                HStack {
//                    //                        SharePlayButton()
//                    ExitAppButton()
//                }
//                .padding()
//                .border(.white, width: 2)
//
//                Spacer()
//
//                // Row 5 - Footnote ("Patent Pending...")
//                FootnoteView()
//                    .border(.blue, width: 2)
//
//            }
//
//        }
//        .frame(width: 1300, height: 900)
//        .fixedSize()
//        .clipped()
//        .overlay {
//            if cor.anyRoomIsLoading {
//                RoomLoadingView()
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(.ultraThinMaterial)
//            }
////        }
//
//    }
//
//}
