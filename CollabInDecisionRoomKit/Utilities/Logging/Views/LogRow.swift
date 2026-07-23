//
//  LogRow.swift
//  Compositor-Services-Interaction
//
//  Created by AidanCarrier on 11/17/25.
//  Copyright © 2025 Apple. All rights reserved.
//


import Combine
import SwiftUI
import os.log


// MARK: - Row

/// A row in ``TerminalView`` which adds a log row when ``OutputLogger`` logs a log message
struct LogRow: View {
    /// The ``LogEntry`` used to construct this ``LogRow``
    let entry: LogEntry

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            PriorityChip(priority: entry.priority)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.message)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                HStack {
                    Text(entry.timestamp, style: .time)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    if let sp = entry.sourcePrefix, !sp.isEmpty {
                        SourceChip(text: sp)
                    }
                    if let tag = entry.tag {
                        TagChip(tag: tag)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    entry.priority.chipBackground.opacity(
                        backgroundOpacity(for: entry.priority)
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    entry.priority.chipBorder,
                    lineWidth: borderWidth(for: entry.priority)
                )
        )
    }

    //TODO: Move to Priority
    
    private func backgroundOpacity(for p: Priority) -> Double {
        switch p {
        case .debug, .info: return 0.0  // blends with background
        case .notice: return 0.20
        case .warning: return 0.25
        case .error: return 0.25
        case .critical: return 0.30
        }
    }

    private func borderWidth(for p: Priority) -> CGFloat {
        switch p {
        case .debug, .info: return 1
        default: return 0
        }
    }
}

// MARK: SourceChip
/// The chip that shows the source of the ``LogEntry``,  e.g. "myFunc() at MyFile:123"
private struct SourceChip: View {
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "scope")  // Alternatives: "scope", "text.magnifyingglass"
            Text(text)
                .lineLimit(1)
        }
        .font(.caption2.bold())
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(Color.secondary.opacity(0.12)))
        .overlay(Capsule().stroke(Color.secondary.opacity(0.35), lineWidth: 1))
        .foregroundStyle(.secondary)
        .fixedSize()
    }
}

// MARK: TagChip
/// The chip that shows the tag, which allows ``LogEntries`` to be filtered
private struct TagChip: View {
    /// The tag string of the  ``LogEntry`` used to construct this chip
    let tag: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "number")
            Text(tag.lowercased())
                .lineLimit(1)
        }
        .font(.caption2.bold())
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule().fill(Color.secondary.opacity(0.15))
        )
        .overlay(
            Capsule().stroke(Color.secondary.opacity(0.35), lineWidth: 1)
        )
        .foregroundStyle(.secondary)
        .fixedSize()
    }
}

// MARK: PriorityChip

/// The chip on the log row indicating the priority of the log message
private struct PriorityChip: View {
    
    /// The priority enum of the ``LogEntry`` used to construct this chip
    let priority: Priority

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: priority.systemImage)
            Text(priority.label)
        }
        .font(.caption.bold())
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule().fill(priority.chipBackground)
        )
        .overlay(
            Capsule().stroke(
                priority.chipBorder,
                lineWidth: priority == .debug || priority == .info ? 1 : 0
            )
        )
        .foregroundStyle(priority.chipForeground)
        .fixedSize()
    }
}
