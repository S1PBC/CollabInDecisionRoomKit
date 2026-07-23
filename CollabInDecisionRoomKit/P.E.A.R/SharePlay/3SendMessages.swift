//
//  3SendMessages.swift
//
//  Created by Ella Isgar on 9/9/25.
//

import Foundation
import GroupActivities

extension SharePlayManager {

    func sendWelcomeNewParticipantMessage(p: Participant) async {

        guard self.activeSession != nil, let messenger = self.messenger else {
            return
        }

        let m =
            WelcomeNewParticipantMessage()

        logger.info(
            """
                    Sending to \(p):
            \(m)
            """
        )

        messenger.send(m, to: .only(p)) { error in
            if let error = error {
                logger.error(
                    "ERROR: WelcomeNewParticipantMessage failed to send --> \(error)"
                )
            }

        }
    }

    func sendCORCommandMessage(_ command: CORCommand) {
        guard let session = self.activeSession,
            let messenger = self.messenger
        else { return }

        let m = CORCommandMessage(action: command.action)

        let everyoneElse = session.activeParticipants.subtracting([
            session.localParticipant
        ])

        logger.info(
            """
            Sending to:
            \(everyoneElse.map { "- \($0.id.uuidString)" }.joined(separator: "\n"))
            \(m)
            """
        )

        messenger.send(m, to: .only(everyoneElse)) { error in
            if let error = error {
                logger.error(
                    "ERROR: CORCommandMessage failed to send --> \(error)"
                )
            }
        }
    }
}
