//
//  OutputLogger.swift
//  OcclusionVision
//
//  Created by AidanCarrier on 8/29/25.
//

import Combine
import Foundation
import SwiftUI
import os.log

// NOTE: Check Target > Build Settings > Search: Default Actor Isolation to see if it is @MainActor or nonisolated

// TODO: Future Addition: @OutputLoggerActor
//@globalActor actor OutputLoggerActor {
//    static var shared = OutputLoggerActor()
//}

/// Custom logging console with verbose toggle.
let logger: OutputLogger = .shared

/// Custom logging class with the ability to toggle whether it's verbose or not.
nonisolated final class OutputLogger : @unchecked Sendable {

    /// The logger for writing interpolated string messages to the unified logging system.
    private let logger: Logger

    /// The shared singleton for the ``OutputLogger`` loads from the file LoggingConfiguration.json in the bundle for options
    static let shared: OutputLogger = {
        do {
            let loggingConfig: Dictionary<String, Bool> = try loadJSON(
                resourceName: "LoggingConfiguration"
            )
            return OutputLogger(
                verbose: loggingConfig["verbose"] ?? true,
                coalescing: loggingConfig["coalescing"] ?? false
            )
        } catch {
            return OutputLogger(verbose: true, coalescing: false)
        }

    }()

    /// A boolean which controls whether logs are printed to the terminal, turning this off would result in no logs printed to terminal while the app is running
    var verbose: Bool

    /// A boolean which controls whether logs are coalesced when the same log is printed to the terminal multiple times.
    var coalescing: Bool

    /// Number of seconds to gather repeats
    var coalesceWindow: TimeInterval

    /// Only summarize if >= this many repeats
    var minRepeatToCoalesce: Int
    
    /// absolute max time to hold a key before force flushing
    var maxHoldBeforeForceFlush: TimeInterval

    /// The log coalescer
    private let coalescer = LogCoalescer()

    /// Boolean determining whether to show the line number in the log entry
    var showLine: Bool

    /// Boolean determining whether to show the function name in the log entry
    var showFunction: Bool

    /// Boolean determining whether to show the file name in the log entry
    var showFile: Bool

    /// The dispatch queue for logging
    private let emitQueue = DispatchQueue(label: "OutputLogger.emit.serial")

    /// Initializes the ``OutputLogger``
    init(
        verbose: Bool,
        coalescing: Bool,
        logger: Logger = Logger(
            subsystem: "DecisionRoomKit.OutputLogger",
            category: "logging"
        ),
        coalesceWindow: TimeInterval = 1.0,
        minRepeatToCoalesce: Int = 2,
        maxHoldBeforeForceFlush: TimeInterval = 5.0,
        showFile: Bool = true,
        showLine: Bool = true,
        showFunction: Bool = true
    ) {
        self.verbose = verbose
        self.coalescing = coalescing
        self.logger = logger
        self.showFile = showFile
        self.showLine = showLine
        self.showFunction = showFunction
        self.coalesceWindow = coalesceWindow
        self.minRepeatToCoalesce = minRepeatToCoalesce
        self.maxHoldBeforeForceFlush = maxHoldBeforeForceFlush
        Task { [coalescer] in
            await coalescer.configure(
                window: self.coalesceWindow,
                minRepeat: self.minRepeatToCoalesce,
                maxHold: self.maxHoldBeforeForceFlush
            )
            log("Logger initialized with coalescing: \(coalescing); (window: \(coalesceWindow), minRepeat: \(minRepeatToCoalesce), maxHold: \(maxHoldBeforeForceFlush))", priority: .notice)
        }
    }

    /// Update coalescing parameters at runtime
    func setCoalescing(
        window: TimeInterval? = nil,
        minRepeat: Int? = nil,
        maxHold: TimeInterval? = nil
    ) {
        if let w = window { coalesceWindow = w }
        if let r = minRepeat { minRepeatToCoalesce = r }
        if let m = maxHold { maxHoldBeforeForceFlush = m }
        Task {
            [
                coalescer, coalesceWindow, minRepeatToCoalesce,
                maxHoldBeforeForceFlush
            ] in
            await coalescer.configure(
                window: coalesceWindow,
                minRepeat: minRepeatToCoalesce,
                maxHold: maxHoldBeforeForceFlush
            )
        }
    }

    /// Flush any buffered summaries immediately (e.g. before app goes to background)
    func flush() {
        Task { [weak self] in
            guard let self else { return }
            await coalescer.flushAll(flushHandler: { [weak self] summary in
                self?.emitQueue.async { [weak self] in
                    self?.emit(
                        summary.message,
                        sourcePrefix: summary.sourcePrefix,
                        tag: summary.tag,
                        priority: summary.priority
                    )
                }

            })
        }
    }

    /// Reset the once keys in the coalescer
    nonisolated func resetOnce() {
        Task { [coalescer] in
            await coalescer.resetOnce()
        }
    }

    /// The mode used for logging.
    ///
    /// Options:
    ///     - throttle: Throttle logs to a specified hertz
    ///     - throttleIdentifiable: Throttle to a specified hertz if it's the same
    ///     - once: Log only once
    enum Mode {
        case throttle, throttleIdentifiable, once
    }

    /// Logs a message with specified priority asynchronously with optional coalescing, throttling (not yet implemented), and one-time emission behavior.
    /// - Parameters:
    ///   - msg: The main log message string to emit.
    ///   - priority: The severity level of the log (`.debug`, `.info`, `.notice`, etc.). Default is `.notice`. This can be filtered in ``TerminalView``
    ///   - tag: An optional string tag to categorize or group logs, this can be filtered in ``TerminalView``
    ///   - once: If `true`, ensures this message is logged only once (via `coalescer.ingest`).
    ///   - throttle: Optional minimum time interval to suppress repeated messages.
    ///   - file: The file in which the log function was called (defaulted to `#file`).
    ///   - function: The function name where the log was called (defaulted to `#function`).
    ///   - line: The line number in the file where the log was called (defaulted to `#line`).
    /// - Note: When `self.coalescing` is true or `once == true`, the log is handled asynchronously in a detached Task.
    ///   Heavy synchronous computation **immediately following** this call may block the executor or event loop,
    ///   delaying or preventing log emission if no other thread resumes the Task in time.
    /// - Complexity: O(1) for synchronous setup; O(n) amortized for coalescer queue handling.
    /// - SeeAlso: ``LogCoalescer``
    func log(
        _ msg: String,
        priority: Priority = .info,
        tag: String? = nil,
        once: Bool = false,
        throttle: TimeInterval? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) { 

        /// The name of the file where the log was called
        let fileName = String(
            "\(file)".split(separator: "/").last?.split(separator: ".").first
                ?? ""
        )
        /// The name of the function where the log was called
        let functionName = String(
            "\(function)".split(separator: "(").first ?? ""
        )

        /// Construct the optional prefix (e.g., "myFunc() at Logger:42") depending on flags.
        let sourcePrefix: String? =
            showFile || showFunction || showLine
            ? "\(showFunction ? "\(functionName)()" : "")"
                + (showFile ? " at \(fileName)" : "")
                + (showLine ? ":\(line)" : "")
            : nil

        /// The message being logged
        let message = msg

        if verbose {
            // If coalescing or `once` is enabled, log asynchronously via the coalescer.
            if self.coalescing || once == true {
                // Create a new asynchronous Task on a cooperative Swift concurrency executor.
                Task { [weak self] in

                    // Safely unwrap `self` weakly captured above.
                    guard let self else { return }

                    // Feed the message into the coalescer
                    await self.coalescer.ingest(

                        message: message,
                        sourcePrefix: sourcePrefix,
                        tag: tag,
                        priority: priority,
                        file: String(describing: file),
                        function: String(describing: function),
                        line: line,
                        coalesce: self.coalescing,
                        once: once

                    ) { [weak self] emitted in
                        // Once the coalescer decides to emit, enqueue it for terminal output.
                        self?.emitQueue.async { [weak self] in
                            self?.emit(
                                emitted.message,
                                sourcePrefix: emitted.sourcePrefix,
                                tag: emitted.tag,
                                priority: emitted.priority
                            )
                        }
                    }
                }
            } else {
                // If coalescing is off, emit immediately and synchronously.
                self.emit(
                    message,
                    sourcePrefix: sourcePrefix,
                    tag: tag,
                    priority: priority
                )
                
            }
        }

    }
    
    func error(
        _ msg: String,
        tag: String? = nil,
        once: Bool = false,
        throttle: TimeInterval? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        self.log(
            msg,
            priority: .error,
            tag: tag,
            once: once,
            throttle: throttle,
            file: file,
            function: function,
            line: line
        )
    }
    
    func debug(
        _ msg: String,
        tag: String? = nil,
        once: Bool = false,
        throttle: TimeInterval? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        
        self.log(
            msg,
            priority: .debug,
            tag: tag,
            once: once,
            throttle: throttle,
            file: file,
            function: function,
            line: line
        )
    }
    
    func notice(
        _ msg: String,
        tag: String? = nil,
        once: Bool = false,
        throttle: TimeInterval? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        
        self.log(
            msg,
            priority: .notice,
            tag: tag,
            once: once,
            throttle: throttle,
            file: file,
            function: function,
            line: line
        )
    }
    
    func critical(
        _ msg: String,
        tag: String? = nil,
        once: Bool = false,
        throttle: TimeInterval? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        
        self.log(
            msg,
            priority: .critical,
            tag: tag,
            once: once,
            throttle: throttle,
            file: file,
            function: function,
            line: line
        )
    }
    
    func warning(
        _ msg: String,
        tag: String? = nil,
        once: Bool = false,
        throttle: TimeInterval? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        
        self.log(
            msg,
            priority: .warning,
            tag: tag,
            once: once,
            throttle: throttle,
            file: file,
            function: function,
            line: line
        )
    }
    
    func info(
        _ msg: String,
        tag: String? = nil,
        once: Bool = false,
        throttle: TimeInterval? = nil,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        
        self.log(
            msg,
            priority: .info,
            tag: tag,
            once: once,
            throttle: throttle,
            file: file,
            function: function,
            line: line
        )
    }

    /// This logs an ``os_log`` message to both the terminal and logs a ``LogEntry`` to ``TerminalView``
    /// - Note: In os_log.logger, .warning is functionally equivalent to .error, so will show up in the terminal with the same severity level, but in terminal view, error will be rated higher than warning
    nonisolated private func emit(
        _ message: String,
        sourcePrefix: String?,
        tag: String?,
        priority: Priority
    ) {
        let osLogMessage: String = {
            guard let sp = sourcePrefix, !sp.isEmpty else { return message }
            return "[\(sp)]:\n\(message)"
        }()
        Task { @MainActor in
            switch priority {
            case .debug: logger.debug("\(osLogMessage, privacy: .public)")
            case .info: logger.info("\(osLogMessage, privacy: .public)")
            case .notice: logger.notice("\(osLogMessage, privacy: .public)")
            case .warning: logger.warning("\(osLogMessage, privacy: .public)")
            case .error: logger.error("\(osLogMessage, privacy: .public)")
            case .critical: logger.critical("\(osLogMessage, privacy: .public)")
            }
        }
        
        logToTerminalView(
            message: message,
            sourcePrefix: sourcePrefix,
            tag: tag,
            priority: priority

        )

    }

    /// Log a  ``LogEntry`` to ``TerminalView``
    nonisolated private func logToTerminalView(
        message: String,
        sourcePrefix: String?,
        tag: String?,
        priority: Priority
    ) {
        let entry = LogEntry(
            message: message,
            sourcePrefix: sourcePrefix,
            tag: tag,
            priority: priority
        )
        Task { @MainActor in
            LogStore.shared.append(entry)
        }
    }

}
