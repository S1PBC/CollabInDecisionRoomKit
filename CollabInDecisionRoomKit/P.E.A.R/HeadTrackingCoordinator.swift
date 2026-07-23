//
//  HeadTrackingCoordinator.swift
//
//  Created by Ella Isgar on 5/19/26.
//

import Observation
import Foundation
import simd

@Observable
class HeadTrackingCoordinator {
    var activeAttachmentID: UUID? = nil
}

func findGazedPanel(
    headTransform H: simd_float4x4,
    panelPositions: [SIMD3<Float>],
    autoPlayEnabled: Bool,
    maxAngleDeg: Float = 15.0
) -> Int? {
    guard autoPlayEnabled, !panelPositions.isEmpty else { return nil }

    let headPos  = SIMD3<Float>(H.columns.3.x, H.columns.3.y, H.columns.3.z)
    let xAxis    = SIMD3<Float>(H.columns.0.x, H.columns.0.y, H.columns.0.z)
    let zAxis    = SIMD3<Float>(H.columns.2.x, H.columns.2.y, H.columns.2.z)

    let enterCos = cos(maxAngleDeg * .pi / 180)

    var bestIndex: Int? = nil
    var bestCos: Float  = enterCos

    for (i, pos) in panelPositions.enumerated() {
        let w     = pos - headPos
        let depth = -simd_dot(zAxis, w)
        guard depth > 0 else { continue }

        let denom = simd_length(w)
        guard denom > 1e-6 else { continue }

        let gazeCos = depth / denom

        if gazeCos > bestCos {
            bestCos   = gazeCos
            bestIndex = i
        }
    }

    if bestIndex != nil {
        print(bestIndex)
    }
    return bestIndex
}

struct HeadTrackingUpdate {
    let source: UUID // head
    let activeID: UUID?
}


extension Notification.Name {
    /// The singular notification name for the head tracking auto play system.
    static let headTrackingUpdated = Notification.Name("headTrackingUpdated")
}
