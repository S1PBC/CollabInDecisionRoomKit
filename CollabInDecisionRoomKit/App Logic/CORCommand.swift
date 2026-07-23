//
//  CORCommand.swift
//
//  Created by Ella Isgar on 12/22/25.
//

import Foundation

/// A lightweight command processing system.
/// Commands are enqueued into a FIFO buffer and executed sequentially
/// in response to Combine-driven signals on a dedicated processing queue.

/// A single executable unit of work for the COR to handle.
struct CORCommand: Identifiable {
    let id = UUID()

    let action: Action

    let source: Source

    /// The action that the COR will take.
    enum Action: Codable {
        case open(UUID)
        case close(UUID)
    }

    /// A CORCommand is either local or from another participant in a SharePlay session. The SharePlay manager uses this value to determine whether to send a CORCommand to all the other players in the SharePlay or prevent a never-ending loop of sending commands to each other.
    enum Source: Equatable, Codable {
        case local
        case shareplaySession
    }
}
