//
//  RoomGeometry+CircularHelix.swift
//  Rooms
//
//  Created by Ella Isgar on 1/28/26.
//

import RealityKit
import SwiftUI

/// A finite segment of a circular helix, discretized into uniformly spaced panels, tangent to a cylinder of radius r, with constant pitch.
class CircularHelixRoomGeometry: RoomGeometry {
    
    /// Total number of panels (+ doors) along the helix.
    var totalNumberOfPanels: Double

    /// Number of panels required to complete one full 360˚ turn.
    var panelsPerRevolution: Double
    
    /// Radius of the cylindrical helix.
    var radius: Double
    
    /// Vertical rise per full revolution.
    var pitch: Double
    
    /// Angular step per panel
    var angleStep: Double
    
    /// Vertical step per panel
    var verticalStep: Double

    /// The world-space offset applied to the entire room geometry.
    ///
    /// This defines where the center of the polygon is located in the scene.
    var roomOriginOffset: SIMD3<Double>
    
    /// Determines what part of the helix the user will be looking at when the room first loads.
    var initialFocusIndex: Double

    /// The current state of the room's drag.
    ///
    /// Dragging updates an accumulated x/y offset that shifts
    /// all panels around the helix.
    var dragState: DragState = DragState()

    /// Private initializer for fully-specified geometry of the helix of a right circular cylinder.
    ///
    /// All geometric parameters must already be computed before calling
    /// this initializer. See the "convenience" inits.
    private init(
        totalNumberOfPanels: Double,
        panelsPerRevolution: Double,
        radius: Double,
        pitch: Double,
        angleStep: Double,
        verticalStep: Double,
        roomOriginOffset: SIMD3<Double>,
        initialFocusIndex: Double
    ) {
        self.totalNumberOfPanels = totalNumberOfPanels
        self.panelsPerRevolution = panelsPerRevolution
        self.radius = radius
        self.pitch = pitch
        self.angleStep = angleStep
        self.verticalStep = verticalStep
        self.roomOriginOffset = roomOriginOffset
        self.initialFocusIndex = initialFocusIndex
    }

    /// Computes the parametric (angular) position of a panel along the helix.
    ///
    /// - Parameters:
    ///     - panel: The panel whose parametric position is requested.
    /// - Returns: A wrapped, continuous index representing angular placement.
    func parametricPosition(of panel: Panel) -> Double {

        let offset = dragState.accumulatedAzimuthOffset

        return (Double(panel.index) + offset)
            .truncatingRemainder(
                dividingBy: totalNumberOfPanels // numberOfSidesPerFloor
            )

    }

    /// Maps a panel’s 1D parametric position into a 3D transform.
    ///
    /// - Parameters:
    ///     - panel: The panel to position.
    /// - Returns: A `Transform` representing the panel’s world-space placement.
    func map1DTo3D(for panel: Panel) -> Transform {

        // SCALE
        let scale: SIMD3<Float> = [1, 1, 1]

        // ROTATION
        let theta = (panel.parametricPosition - initialFocusIndex) * angleStep
        
        let inward = SIMD3<Double>(
            -sin(theta),
             0,
             cos(theta)
        )
        
        // let yaw = atan2(inward.x, inward.z) + .pi
        let yaw = atan2(inward.x, inward.z) + .pi
        
        let rotation = simd_quatf(angle: Float(yaw), axis: SIMD3<Float>(0, 1, 0))
        
        // TRANSLATION
        let x = radius * sin(theta)
        let y = panel.parametricPosition * verticalStep
                + dragState.accumulatedInclinationOffset
                + roomOriginOffset.y
        let z = -radius * cos(theta)
        
        let translation: SIMD3<Float> = [Float(x), Float(y), Float(z)]
        
        return Transform(
            scale: scale,
            rotation: rotation,
            translation: translation
        )

    }

    func processDragGesture(
        _ dragGesture: EntityTargetValue<DragGesture.Value>
    ) {
        let current = dragGesture.convert(
            dragGesture.location3D,
            from: .local, to: .scene
        )
        let predicted = dragGesture.convert(
            dragGesture.predictedEndLocation3D,
            from: .local, to: .scene
        )

        let movement = predicted - current

        // ── Direction (new tangent-based logic, camera-independent) ──
        let roomCenter = SIMD3<Float>(
            Float(roomOriginOffset.x), current.y, Float(roomOriginOffset.z)
        )
        let radial = current - roomCenter
        guard length(radial) > 0.0001 else { return }

        let tangent = SIMD3<Float>(-radial.z, 0, radial.x)
        let normalizedTangent = normalize(tangent)
        let lateralSign = sign(Double(dot(normalizedTangent, movement)))

        let dragDimension = abs(movement.y) / length(movement)

        // ── Magnitude (original velocity-based scaling) ──
        if dragDimension > 0.7 {
            let inclinationVelocityFactor =
                0.2 / 70 * (dragGesture.velocity.height.magnitude / 1000)
            let inclinationDirection = sign(Double(-dragGesture.velocity.height))
            dragState.accumulatedInclinationOffset +=
                inclinationDirection * inclinationVelocityFactor

        } else if dragDimension < 0.6 {
            let azimuthVelocityFactor =
                0.2 * (dragGesture.velocity.width.magnitude / 1000)
            dragState.accumulatedAzimuthOffset +=
                lateralSign * (azimuthVelocityFactor / 180 * π)
        }
    }

}

// MARK: Public initializers
extension CircularHelixRoomGeometry {

    public convenience init(
        totalNumberOfPanels: Int,
        panelsPerRevolution: Int = 10,
        panelWidth: Float,
        horizontalPanelPadding: Float,
        panelHeight: Float,
        verticalPanelPadding: Float,
        roomOriginOffset: SIMD3<Float> = [0, 0, 0],
        initialFocusIndex: Float
    ) {
        
        let totalNumberOfPanels_d = Double(totalNumberOfPanels)
        let panelsPerRevolution_d = Double(panelsPerRevolution)
        
        // Compute radius so panels tile perfectly around one revolution.
        let radius_d = Double(panelWidth + horizontalPanelPadding) / (2.0 * tan(π / panelsPerRevolution_d))
        
        let pitch_d = Double(panelHeight + verticalPanelPadding) // Double(pitch)

        let angleStep_d = (2 * π) / (panelsPerRevolution_d)
        let verticalStep_d = pitch_d / panelsPerRevolution_d

        let roomOriginOffset_d = SIMD3<Double>(roomOriginOffset)
        
        let initialFocusIndex_d = Double(initialFocusIndex)

        self.init(
            totalNumberOfPanels: totalNumberOfPanels_d,
            panelsPerRevolution: panelsPerRevolution_d,
            radius: radius_d,
            pitch: pitch_d,
            angleStep: angleStep_d,
            verticalStep: verticalStep_d,
            roomOriginOffset: roomOriginOffset_d,
            initialFocusIndex: initialFocusIndex_d
        )
    }

}
