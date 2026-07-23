//
//  LogCoalescer.swift
//  OccluVision
//
//  Created by AidanCarrier on 10/21/25.
//

import Combine
import Foundation
import SwiftUI

/// A concurrency-safe buffer that coalesces repeated log lines into ROS-like summaries.
/// Policy:
///  - Identical key seen again within `window` ⇒ increment count, suppress emission
///  - On key change OR window expiry ⇒ emit summary: "… (repeated N× in T s)"
///  - Force flush any held key after `maxHold`
actor LogCoalescer {

    struct Key: Hashable {
        let textHash:   Int
        let priority:   Priority
        let tag:        String?
        let file:       String
        let function:   String
        let line:       UInt
    }

    struct OnceKey: Hashable {
        let file: String
        let function: String
        let line: UInt
    }

    private var seenOnce: Set<OnceKey> = []

    struct Held {
        var firstTime: CFAbsoluteTime
        var lastTime: CFAbsoluteTime
        var count: Int
        var message: String
        var sourcePrefix: String?
        var tag: String?
        var priority: Priority
    }

    struct Emitted {
        let message: String
        let sourcePrefix: String?
        let tag: String?
        let priority: Priority
    }

    //TODO: These are defaults, but shouldn't include defaults here, include them in configure()
    private var window: TimeInterval = 1.0
    private var minRepeat: Int = 2
    private var maxHold: TimeInterval = 5.0

    // Track only the current key for memory
    private var currentKey: Key?
    private var current: Held?

    // Timer for deadline-based flush
    private var timer: DispatchSourceTimer?

    func configure(window: TimeInterval, minRepeat: Int, maxHold: TimeInterval)
    {
        self.window = window
        self.minRepeat = max(1, minRepeat)
        self.maxHold = maxHold
        restartTimer()
    }

    func resetOnce() {
        seenOnce.removeAll()
    }

    /// Ingest a message into the coalescer, checking for "once" flags, "throttle"
    func ingest(
        message: String,
        sourcePrefix: String?,
        tag: String?,
        priority: Priority,
        file: String,
        function: String,
        line: UInt,
        coalesce: Bool,
        once: Bool,
        emit: @Sendable (Emitted) -> Void
    ) {

        if once {
            let ok = OnceKey(
                file:       file,
                function:   function,
                line:       line,
            )
            if seenOnce.contains(ok) {
                return  // suppress entirely
            } else {
                seenOnce.insert(ok)
                // Emit immediately and do not touch coalescing state
                emit(
                    Emitted(
                        message: message,
                        sourcePrefix: sourcePrefix,
                        tag: tag,
                        priority: priority
                    )
                )
                return
            }
        }

        if !coalesce {
            emit(
                Emitted(
                    message: message,
                    sourcePrefix: sourcePrefix,
                    tag: tag,
                    priority: priority
                )
            )
            return
        }

        let now = CFAbsoluteTimeGetCurrent()
        let combined = [message, sourcePrefix ?? "", tag ?? ""].joined(separator: "\u{1F}")
        let key = Key(
            textHash: combined.hashValue,
            priority: priority,
            tag: tag,
            file: file,
            function: function,
            line: line
        )

        if let k = currentKey, var h = current, k == key {
            // Same key as current
            if (now - h.lastTime) <= window {
                h.count += 1
                h.lastTime = now
                current = h
                return  // suppress, keep coalescing
            } else {
                // Window elapsed for same key ⇒ emit summary (if enough repeats), then start fresh
                emitSummaryIfNeeded(held: h, emit: emit)
                currentKey = key
                current = Held(
                    firstTime: now,
                    lastTime: now,
                    count: 1,
                    message: message,
                    sourcePrefix: sourcePrefix,
                    tag: tag,
                    priority: priority
                )
                emit(
                    Emitted(
                        message: message,
                        sourcePrefix: sourcePrefix,
                        tag: tag,
                        priority: priority
                    )
                )  // first in new window prints
                return
            }
        }

        // New key different from current ⇒ summarize current and switch
        if let h = current {
            emitSummaryIfNeeded(held: h, emit: emit)
        }

        currentKey = key
        current = Held(
            firstTime: now,
            lastTime: now,
            count: 1,
            message: message,
            sourcePrefix: sourcePrefix,
            tag: tag,
            priority: priority
        )
        emit(
            Emitted(
                message: message,
                sourcePrefix: sourcePrefix,
                tag: tag,
                priority: priority
            )
        )
    }

    func flushAll(flushHandler: (Emitted) -> Void) {
        if let h = current {
            emitSummaryIfNeeded(held: h, emit: flushHandler, force: true)
            current = nil
            currentKey = nil
        }
    }

    // MARK: - Internals

    private func emitSummaryIfNeeded(
        held h: Held,
        emit: (Emitted) -> Void,
        force: Bool = false
    ) {
        guard h.count >= minRepeat || force else { return }
        // For count >= 2, we already emitted the first occurrence; the “repeated N×” should reflect extra appearances.
        let repeats = max(0, h.count - 1)
        guard repeats > 0 || force else { return }
        let dt = max(0.0, h.lastTime - h.firstTime)
        let formatted = String(
            format: "%@ (repeated %d× in %.2fs)",
            h.message,
            repeats,
            dt
        )
        emit(
            Emitted(
                message:        formatted,
                sourcePrefix:   h.sourcePrefix,
                tag:            h.tag,
                priority:       h.priority
            )
        )
    }

    private func restartTimer() {
        timer?.cancel()
        let t = DispatchSource.makeTimerSource(queue: .global(qos: .utility))
        t.schedule(
            deadline: .now() + .milliseconds(500),
            repeating: .milliseconds(500)
        )
        t.setEventHandler { [weak self] in
            Task { await self?.onTick() }
        }
        t.resume()
        timer = t
    }

    private func onTick(delay: CFAbsoluteTime = 0.0001) {
        guard var h = current else { return }
        let now = CFAbsoluteTimeGetCurrent()

        // Force flush if we've held too long
        if (now - h.firstTime) >= maxHold {
            // We can’t emit directly from here since we don’t have the emit closure.
            // Strategy: clear state; the logger should call `flush()` before shutdown,
            // but to be safe we convert "force flush" into "window elapsed" behavior by
            // artificially reducing the count to avoid infinite hold.
            // Instead, we’ll mark lastTime far enough back so next ingest will emit summary immediately.
            h.lastTime = h.firstTime + window + delay
            current = h
        }
    }
}
