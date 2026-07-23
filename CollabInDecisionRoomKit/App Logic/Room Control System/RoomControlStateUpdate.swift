//
//  RoomControlStateUpdate.swift
//  DecisionRoomKit
//
//  Created by Ella Isgar on 5/19/26.
//

import Foundation


extension Notification.Name {
    /// The singular notification name for the whole Room's Control system.
    static let controlStateUpdated = Notification.Name("controlStateUpdated")
}


/// Represents the new state of the RoomControl posting this update.
/// When a user toggles a RoomControl, the control posts its RoomControlUIState. Targets use their binding's intendedAction to interpret it.
struct RoomControlStateUpdate {

    /// ID of the RoomControl that is posting this update.
    let source: UUID

    /// The newly updated state.
    let state: RoomControlUIState // control just reports its own UI state

}
