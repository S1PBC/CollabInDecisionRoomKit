//
//  LogStore.swift
//  OccluVision
//
//  Created by AidanCarrier on 10/21/25.
//
import Combine
import Foundation
import SwiftUI

/// A log entry struct, which contains the information outputted to ``TerminalView``
struct LogEntry: Identifiable, Equatable, Hashable {
    let id:             UUID    = UUID()
    let message:        String
    let sourcePrefix:   String?
    let tag:            String?
    let priority:       Priority
    let timestamp:      Date    = Date()
}

/// A type alias for a list of ``LogEntry`` structs
typealias LogEntries = [LogEntry]

/// An observable object 'store' that contains the ``LogEntry``, runs on the` @MainActor` because interacts with SwiftUI views
@MainActor
final class LogStore: ObservableObject {
    
    /// Lazily initialized shared single on
    static let shared = LogStore()
    
    /// The stored log entries
    @Published private(set) var entries: LogEntries = []
    
    /// A boolean that determines if this store is paused, which sends LogEntries to
    @Published private(set) var isPaused: Bool = false
    
    /// The number of elements in the ``backlog``
    @Published private(set) var backlogCount: Int = 0

    /// The backlog
    private(set) var backlog: LogEntries = []

    /// Append a ``LogEntry`` to ``entries`` if not paused, if paused appends to ``backlog``
    public func append(_ entry: LogEntry) {
        if isPaused {
            backlog.append(entry)
            backlogCount = backlog.count
        } else {
            entries.append(entry)
        }
    }

    /// Clear all ``LogEntries`` from the ``entries`` and ``backlog`` arrays
    public func clear() {
        entries.removeAll()
        backlog.removeAll()
        backlogCount = 0
    }

    /// Pause sending the logs to ``entries`` and send them to ``backlog`` instead
    public func setPaused(_ paused: Bool) {
        // Exit if the paused state is the current isPaused state
        guard paused != isPaused else { return }
        // Set paused
        isPaused = paused
        // If unpaused, empty the ``backlog`` into ``entries``
        if !paused && !backlog.isEmpty {
            // release buffered logs in a single batch (minimize UI churn)
            entries.append(contentsOf: backlog)
            backlog.removeAll(keepingCapacity: true)
            backlogCount = 0
        }
    }
}
