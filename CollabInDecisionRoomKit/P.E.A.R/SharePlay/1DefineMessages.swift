//
//  1DefineMessages.swift
//
//  Created by Ella Isgar on 8/13/25.
//

import Combine
import Foundation
import GroupActivities


/**
 All the information needed to join an active group session, regardless of whether a game is in-progress or not.
 
 This Message is sent to every newly joined participant of the active group session.
 */
struct WelcomeNewParticipantMessage: Message {
    
}

/**
 The information of a participant's CORCommand.
 
 This Message is sent to everyone whenever a CORCommand is created by the local participant (e.g. the participant attempted to open a new room).
 */
struct CORCommandMessage: Message {
    let action: CORCommand.Action
}

/**
 The blueprint for any message sent between participants during an active SharePlay of the Color Guessing game activity.
 
 This Message protocol must be adopted by the struct of any message type.
 
 - Requires: Adoption of the _codable_ protocol because a Message sent by the GroupSessionMessenger must be en- and de- codable.
 */
protocol Message: Codable, CustomStringConvertible {
    var description: String { get }
}

extension Message {
    /// The pretty-printed version of a Message
    var description: String {
        let mirror = Mirror(reflecting: self)
        let typeName = String(describing: type(of: self))

        var lines: [String] = ["====== \(typeName) ======"]

        for child in mirror.children {
            if let label = child.label {
                lines.append("\(label): \(child.value)")
            } else {
                lines.append("\(child.value)")
            }
        }

        lines.append(
            "====== \(String(repeating: "=", count: typeName.count)) ======")

        return lines.joined(separator: "\n")
    }
}
