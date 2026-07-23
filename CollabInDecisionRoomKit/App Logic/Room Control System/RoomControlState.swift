//
//  RoomControlState.swift
//
//  Created by Ella Isgar on 5/7/26.
//

import Foundation

/// Represents the state of a RoomControl.

/// The actions that a target of a RoomControl can potentially take when triggered by a RoomControl (posting a RoomControlStateUpdate).
// enum RoomControlTargetAction {
enum RoomControlState {

    // Attachment actions
    case toggle_visibility(Bool)
    case refresh
    case toggle_stream(Bool)
    case toggle_flip(Bool)
    case toggle_headTrackedAutoplay(Bool)

    // Panel actions
    case toggle_panel_transparency(Bool)

    // Head tracking system
    case activeAttachment(id: UUID?)
}

extension RoomControlState {
    /// Returns true if both states are the same case, regardless of associated value.
    func isSameCase(as other: RoomControlState) -> Bool {
        switch (self, other) {
        case (.toggle_visibility, .toggle_visibility),
            (.toggle_stream, .toggle_stream),
            (.toggle_flip, .toggle_flip),
            (.toggle_headTrackedAutoplay, .toggle_headTrackedAutoplay),
            (.toggle_panel_transparency, .toggle_panel_transparency),
            (.activeAttachment, .activeAttachment),
            (.refresh, .refresh):
            return true
        default:
            return false
        }
    }
}
