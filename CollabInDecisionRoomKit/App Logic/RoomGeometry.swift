//
//  RoomGeometry.swift
//
//  Created by Ella Isgar on 11/24/25.
//

import RealityKit
import SwiftUI

protocol RoomGeometry {

    var dragState: DragState { get set }

    func parametricPosition(of panel: Panel) -> Double

    func map1DTo3D(for panel: Panel) -> Transform

    func processDragGesture(
        _ dragGesture: EntityTargetValue<DragGesture.Value>,
        // cameraRightDirectionVector: SIMD3<Float>
    )

}
