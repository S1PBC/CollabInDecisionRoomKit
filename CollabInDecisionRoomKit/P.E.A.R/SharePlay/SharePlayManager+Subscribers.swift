//
//  SharePlayManager+Subscribing.swift
//
//  Created by Ella Isgar on 12/18/25.
//

import GroupActivities

// Subscribers to the Controller of Rooms's publishers
extension SharePlayManager {
    
    func subscribeToCORCommands() {
        cor.getCommandPublisher()
            .sink { [weak self] command in
                self?.handleCORCommand(command)
            }
            .store(in: &corSubscriptions)
    }
    
    func handleCORCommand(_ command: CORCommand) {

        // We are only sending out CORCommands that were created locally. Do not remove this filter unless you want every SharePlayManager to get caught in an endless loop of sending each other CORCommands.
        guard command.source != .shareplaySession else { return }
        
        sendCORCommandMessage(command)
        
    }
    
}

// Subscribers to an Active SharePlay Session's publishers
extension SharePlayManager {

    func subscribeToState(_ session: GroupSession<RoomsGroupActivity>) {

        // the .sink operator is used to attach a subscriber to a publisher
        session.$state
            .sink { state in
                Task {
                    await self.handleStateChange(state)
                }
            }
            .store(in: &self.activeSessionSubscriptions)
    }

    func subscribeToActiveParticipants(
        _ session: GroupSession<RoomsGroupActivity>
    ) {
        session.$activeParticipants
            .sink { updatedActiveParticipants in
                Task {
                    await self.handleActiveParticipantsChange(
                        updatedActiveParticipants)
                }
            }
            .store(in: &self.activeSessionSubscriptions)
    }

    func handleStateChange(
        _ state: GroupSession<RoomsGroupActivity>.State
    ) async {

        switch state {
        case .invalidated:
            logger.notice("Session is no longer valid.")

            self.activeSession = nil
            self.myID = nil
            self.messenger = nil
            self.activeSessionSubscriptions = []
            self.tasks.forEach { $0.cancel() }
            self.tasks = []
            self.previousActiveParticipants = []

        case .waiting:
            logger.notice(
                "Session waiting for app to join the RoomGroupActivity.")
            return
        case .joined:
            logger.notice(
                "Session now allows data synchronization between devices.")

            return

        @unknown default:
            return
        }
    }

    func handleActiveParticipantsChange(
        _ updatedActiveParticipants: Set<Participant>
    ) async {

        let currentParticipants = Set(updatedActiveParticipants)
        let previousParticipants = previousActiveParticipants

        let newlyJoined = currentParticipants.subtracting(previousParticipants)
        let justLeft = previousParticipants.subtracting(currentParticipants)

        if !newlyJoined.isEmpty {
            logger.notice(
                """
                Newly joined:
                \(newlyJoined.map { "- \($0.id.uuidString)" }.joined(separator: "\n"))

                """)
        }

        if !justLeft.isEmpty {
            logger.notice(
                """
                Just left:
                \(justLeft.map { "- \($0.id.uuidString)" }.joined(separator: "\n"))

                """)
        }

        for p in newlyJoined {
            if p.id != myID {
                await sendWelcomeNewParticipantMessage(p: p)
            }
        }

        self.previousActiveParticipants = currentParticipants
    }
}
