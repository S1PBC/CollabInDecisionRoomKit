//
//  CollabInDecisionRoomKitApp.swift
//  CollabInDecisionRoomKit
//
//  Created by Ella Isgar on 11/24/25.
//

import SwiftUI
import GroupActivities

@main
struct CollabInDecisionRoomKitApp: App {
    
    /// All logic of the app.
    @State private var app: AppLogic

    /// For convenience to reference the app's controller of rooms.
    @State private var controllerOfRooms: ControllerOfRooms

    /// For convenience to reference the app's instance of P.E.A.R that is reponsible for the perception of ``controllerOfRooms``.
    @State private var pear: PEAR

    init() {
        let app = AppLogic()
        self.controllerOfRooms = app.controllerOfRooms
        self.pear = app.pear
        self.app = app
    }

    var body: some Scene {

        WindowGroup {
            ContentView()
                .environment(app)
                .environment(controllerOfRooms)
                .environment(pear)
                // NOTE: allowing = "*" ==> this window is allowed to handle any other event. The [*] is a wildcard. Without this handler, identical windows would pop up everytime any external event ever happens (e.g. SharePlay)
                .handlesExternalEvents(
                    preferring: Set(arrayLiteral: "pause"),
                    allowing: Set(arrayLiteral: "*")
                )
                .handlesExternalEvents(
                    preferring: [RoomsGroupActivity.activityIdentifier],
                    allowing: [RoomsGroupActivity.activityIdentifier]
                )
        }
        .windowResizability(.contentSize)

        ImmersiveSpace(id: app.immersiveSpaceID) {
            ImmersiveView()
                .environment(app)
                .environment(controllerOfRooms)
                .environment(pear)
        }
    }
}
