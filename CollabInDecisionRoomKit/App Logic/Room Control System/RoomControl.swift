//
//  RoomControl.swift
//
//  Created by Ella Isgar on 2/25/26.
//

import Foundation
import Observation
import RealityKit

/// A UI control that posts its own state as its changed via the NotificationCenter. A target object (e.g. RoomAttachment) that is binded to a RoomControl will observe the NotificationCenter for that RoomControl's .controlStateUpdated postings and react accordingly.
@Observable
class RoomControl: Identifiable, Equatable {

    /// The globally unique ID of the control.
    let id = UUID()

    // TODO: Combine w the RoomControlState. State drives UI.
    let label: String
    let altLabel: String?  // shows when stateful action is ON

    /// The current state of the control.
    var state: RoomControlUIState

    // TODO: Undefined behavior -> what happens when RoomControl is binded to multiple attachments associated with multiple panels.
    /// The panel, if one exists, of the attachment that the RoomControl is binded to.
    var panelIndex: Int = -1  // -1 == control not associated with any attachment on a panel

    init(
        label: String,
        altLabel: String? = nil,
        initialUIState: RoomControlUIState
    ) {
        self.label = label
        self.altLabel = altLabel
        self.state = initialUIState
    }

    /// Creates a notification named `controlStateUpdated` and posts a ``RoomControlStateUpdate`` to the notification center.
    func postUpdatedControlState(_ newState: RoomControlUIState) {

        self.state = newState

        logger.info(
            """
            Control State Update:
            - \(id)
            - aka [\(label)/\(altLabel ?? "_")]
            - new state = \(newState)
            """
        )

        NotificationCenter.default.post(
            name: .controlStateUpdated,
            object: RoomControlStateUpdate(source: id, state: newState)
        )
    }

    /// Conformance to the equtable protocol.
    static func == (lhs: RoomControl, rhs: RoomControl) -> Bool {
        return lhs.id == rhs.id
    }

}
