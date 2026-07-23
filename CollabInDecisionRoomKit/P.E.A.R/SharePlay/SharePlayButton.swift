//
//  SharePlayButton.swift
//
//  Created by Ella Isgar on 12/18/25.
//

import GroupActivities
import SwiftUI
import UIKit

struct SharePlayButton: View {

    @Environment(PEAR.self) var pear

    // Determines if a FaceTime is happening (if so, then SharePlay experience is possible)
    @StateObject var groupStateObserver = GroupStateObserver()

    @State var isActivitySharingSheetPresented: Bool = false

    var body: some View {
        
        Button(
            "Share Rooms",
            systemImage: (pear.sharePlayManager.activeSession != nil
                ? "shareplay" : "shareplay.slash"),
            action: {

                // If a FaceTime is active, begin SharePlay immediately
                if groupStateObserver.isEligibleForGroupSession {
                    pear.sharePlayManager.startActivity()
                } else {
                    // Present a GroupActivitySharingController, which prompts the person to invite others to join the activity
                    isActivitySharingSheetPresented = true
                }

            }
        )
        .font(.title2)
        .tint(
            pear.sharePlayManager.activeSession != nil
                ? .green : Color.black.opacity(0.2)
        )
        .sheet(isPresented: $isActivitySharingSheetPresented) {
            ActivitySharingViewController(
                activity: RoomsGroupActivity()
            )
        }
    }
}

struct ActivitySharingViewController: UIViewControllerRepresentable {

    let activity: GroupActivity

    func makeUIViewController(context: Context)
        -> GroupActivitySharingController
    {
        return try! GroupActivitySharingController(activity)
    }

    func updateUIViewController(
        _ uiViewController: GroupActivitySharingController,
        context: Context
    ) {}
}
