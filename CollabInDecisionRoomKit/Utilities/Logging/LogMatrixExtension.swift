//
//  LogMatrixExtension.swift
//  Compositor-Services-Interaction
//
//  Created by AidanCarrier on 12/2/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import simd
import Foundation

extension OutputLogger {
    
    public func logMatrix(_ name: String, _ matrix: float4x4, priority: Priority = .notice, tag: String? = "matrix", once: Bool = false,
                   throttle: TimeInterval? = nil, function: StaticString = #function, file: StaticString = #file, line: UInt = #line) { 
        
        log("\(name) (4x4):\n\(matrix4x4ToString(matrix))\n---\nraw: \(matrix)", priority: priority, tag: tag, once: once, throttle: throttle, file: file, function: function, line: line)
    }
    
    public func logMatrix(_ name: String, _ matrix: float3x3, priority: Priority = .notice, tag: String? = "matrix", once: Bool = false,
                   throttle: TimeInterval? = nil, function: StaticString = #function, file: StaticString = #file, line: UInt = #line) {
        
        log("\(name) (3x3):\n\(matrix3x3ToString(matrix))\n---\nraw: \(matrix)", priority: priority, tag: tag, once: once, throttle: throttle, file: file, function: function, line: line)
        
        //matrix.logIntrinsicsParameters()
    }
    
    public func logMatrix(_ name: String,
                       _ matrix: simd_float4x3,
                       priority: Priority = .notice,
                       tag: String? = "matrix",
                       once: Bool = false,
                       throttle: TimeInterval? = nil,
                       function: StaticString = #function,
                       file: StaticString = #file,
                       line: UInt = #line)
        {
            log("\(name) (4x3):\n\(matrix4x3ToString(matrix))\n---\nraw: \(matrix)",
                priority: priority,
                tag: tag,
                once: once,
                throttle: throttle,
                file: file,
                function: function,
                line: line)
        }
}
