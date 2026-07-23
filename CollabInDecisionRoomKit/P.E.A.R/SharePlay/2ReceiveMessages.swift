//
//  2ReceiveMessages.swift
//
//  Created by Ella Isgar on 8/14/25.
//

import Foundation
import GroupActivities

/// The logic to process any Message type received by the GroupSessionManager is defined and implemented here.
extension SharePlayManager {

    func addMessageHandlers() {

        // WelcomeNewParticipantMessage
        handleMessage(messageType: WelcomeNewParticipantMessage.self) {
            m, context in
        }

        // CORCommandMessage
        handleMessage(messageType: CORCommandMessage.self) {
            [self] m, context in
            Task {
                let command = CORCommand(
                    action: m.action,
                    source: .shareplaySession
                )
                
                cor.submit(command)
            }
        }
        
    }

    /**
     THE handleMessage function.
     * Parameters:
        * messageType: a specific implementation of the Message Protocol (see 1DefineMessages)
        * condition: an optional parameter that filters messages BEFORE handling them
            * NOTE: condition only knows about the outer state, not the message or context.
        * handler: the logic to handle the incoming message
     */
    func handleMessage<Message: Codable>(
        // from messenger: GroupSessionMessenger?,
        messageType: Message.Type,
        condition: @escaping () async -> Bool = { true },
        handler: @escaping (Message, GroupSessionMessenger.MessageContext) ->
            Void
    ) {

        guard let messenger = self.messenger else { return }

        tasks.insert(
            Task { @MainActor in
                for await (message, context) in messenger.messages(
                    of: Message.self)
                {
                    if await condition() {

                        let toLog: String =
                            "Received following message from \(context.source.id.uuidString):\n\(message)"
                        logger.info("\(toLog)")
                        handler(message, context)
                    }
                }
            }
        )
    }
}
