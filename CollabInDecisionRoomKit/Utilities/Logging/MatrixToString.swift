//
//  MatrixToString.swift
//  BREVA
//
//  Created by AidanCarrier on 12/3/25.
//

import simd

nonisolated public func matrix4x4ToString(_ m: float4x4) -> String {
    var s = ""
    for row in 0..<4 {
        s += String(
            format: "[ % .6f, % .6f, % .6f, % .6f ]\n",
            m.columns.0[row],
            m.columns.1[row],
            m.columns.2[row],
            m.columns.3[row]
        )
    }
    return s
}

nonisolated public func matrix3x3ToString(_ m: float3x3) -> String {
    var s = ""
    for row in 0..<3 {
        s += String(
            format: "[ % .4f, % .4f, % .4f ]\n",
            m.columns.0[row],
            m.columns.1[row],
            m.columns.2[row]
        )
    }
    return s
}

nonisolated public func matrix4x3ToString(_ m: float4x3) -> String {
    var s = ""
    for row in 0..<3 {
        s += String(
            format: "[ % .6f, % .6f, % .6f, % .6f ]\n",
            m.columns.0[row],
            m.columns.1[row],
            m.columns.2[row],
            m.columns.3[row]
        )
    }
    return s
}
