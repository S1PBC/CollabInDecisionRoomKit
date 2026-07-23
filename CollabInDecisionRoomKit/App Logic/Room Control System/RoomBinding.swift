//
//  RoomBinding.swift
//
//  Created by Ella Isgar on 5/7/26.
//

import Foundation

/// Represent one wiring between a RoomControl, a target (e.g., RoomAttachment), and a RoomControlTargetAction, the intended action for the target to take upon observing a newly posted RoomControlStateUpdate.
class RoomBinding {

    /// ID of a RoomControl
    let control: UUID

    /// ID of a target object (e.g. attachment)
    let target: UUID

    /// The intended action that the target will execute upon receiving a new RoomControlStateUpdate from the control.
    let intendedAction: RoomControlState

    /// The initial state of the control when the room is loaded. The target will reflect the control's current state.
    let initialState: RoomControlUIState

    init(
        control: UUID,
        target: UUID,
        intendedAction: RoomControlState,
        initialState: RoomControlUIState
    ) {
        self.control = control
        self.target = target
        self.intendedAction = intendedAction
        self.initialState = initialState
    }

}
