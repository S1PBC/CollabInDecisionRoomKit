//
//  SharePlayManager.swift
//
//  Created by Ella Isgar on 12/18/25.
//

import Combine
import GroupActivities
import LinkPresentation
import SwiftUI
import os

@Observable
class SharePlayManager {

    var cor: COR

    var allSessions: [GroupSession<RoomsGroupActivity>]

    var activeSession: GroupSession<RoomsGroupActivity>?

    var myID: UUID?

    var messenger: GroupSessionMessenger?

    var tasks: Set<Task<Void, Never>>

    var corSubscriptions: Set<AnyCancellable>
    var activeSessionSubscriptions: Set<AnyCancellable>

    var previousActiveParticipants: Set<Participant>

    private var timer: Timer?

    init(for controllerOfRooms: ControllerOfRooms) {
        self.cor = controllerOfRooms
        self.allSessions = []
        self.tasks = []
        self.corSubscriptions = []
        self.activeSessionSubscriptions = []
        self.previousActiveParticipants = []

        subscribeToCORCommands()
    }

    func registerRoomsGroupActivity() {
        // Create the activity
        let activity = RoomsGroupActivity()

        // Register the activity on the item provider
        let itemProvider = NSItemProvider()
        itemProvider.registerGroupActivity(activity)

        // Create the activity items configuration
        let configuration = UIActivityItemsConfiguration(itemProviders: [
            itemProvider
        ])

        // Provide the metadata for the group activity
        configuration.metadataProvider = { key in
            guard key == .linkPresentationMetadata else { return }
            let metadata = LPLinkMetadata()
            metadata.title = String("The ColorGuessing Game")
            return metadata
        }
        // This adds the activity with the specified configuration to the SharePlay menu. How exactly it reaches the SharePlay menu/window is unknown, however, it is required to add it to the menu so that you can start the SharePlay from the SharePlay Menu. This is where the code exposes the configuration to the menu directly.
        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first?
            .rootViewController?
            .activityItemsConfiguration = configuration
    }

    func configureGroupSession(
        session: GroupSession<RoomsGroupActivity>
    ) async {

        self.allSessions.append(session)
        self.activeSession = session

        self.myID = session.localParticipant.id
        logger.info("My ID is \(session.localParticipant.id.uuidString)")

        // Configure group's ImmersiveSpace
        // guard let systemCoordinator = await session.systemCoordinator else { return }

        self.messenger = GroupSessionMessenger(session: session)
        addMessageHandlers()

        subscribeToState(session)
        subscribeToActiveParticipants(session)

        // Join the session.
        session.join()
    }

    func startActivity() {
        Task {
            do {
                _ = try await RoomsGroupActivity().activate()
            } catch {
                logger.error(
                    "ERROR: Failed to activate RoomsGroupActivity."
                )
            }
        }
    }
}
