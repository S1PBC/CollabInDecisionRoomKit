//
//  Priority.swift
//  OccluVision
//
//  Created by AidanCarrier on 11/13/25.
//

import Combine
import Foundation
import SwiftUI
import os.log


/// The priority or severity level of a log logged into the terminal and/or of the ``LogEntry`` logged into ``TerminalView``.
///
/// There are six levels of priority:
/// * ``debug``          : Equivalent to` os_log.debug`
/// * ``info``            : Equivalent to `os_log.info`
/// * ``notice``        : Equivalent to` os_log.notice`
/// * ``warning``      : Equivalent to `os_log.error`, see note below
/// * ``error``          : Equivalent to `os_log.error`
/// * ``critical``   : Equivalent to `os_log.critical`
///
/// - Note:In os_log.logger, .warning is functionally equivalent to .error, so will show up in the terminal with the same severity level, but in terminal view, error will be rated higher than warning
enum Priority: String, CaseIterable, Codable {

    case debug, info, notice, warning, error, critical

    /// The label of the chip
    var label: String { rawValue.uppercased() }

    /// The system image associated with the chip
    var systemImage: String {
        switch self {

        case .critical: return "exclamationmark.octagon.fill"
            
        case .error: return "exclamationmark.triangle.fill"
            
        case .warning: return "exclamationmark.circle.fill"
            
        case .notice: return "bell.fill"
            
        case .info: return "info"
            
        case .debug: return "ladybug"

        }
    }

    /// Computed variable for the foreground color of the chip
    var chipForeground: Color {
        switch self {
        case .critical: return .white
        case .error: return .white
        case .warning: return .black
        case .notice: return .white
        case .info, .debug:
            return .secondary
        }
    }

    /// Computed variable for the background color of the chip
    var chipBackground: Color {
        switch self {
        case .critical: return .red
        case .error: return .orange
        case .warning: return .yellow
        case .notice: return .blue
        case .info, .debug:
            return .clear
        }
    }

    /// Computed variable for the color of the chip border.
    var chipBorder: Color {
        switch self {
        case .info, .debug:
            return .secondary.opacity(0.35)
        default:
            return .clear
        }
    }
}
