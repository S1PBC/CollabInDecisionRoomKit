//
//  RoomGeometry+NewCircularRG.swift
//  Rooms
//
//  Created by Ella Isgar on 4/9/26.
//


// NOTES:
// the circle is a "constrained maximum inscribed circle"

import RealityKit
import SwiftUI

/// A ``RoomGeometry`` implementation that arranges panels along the
/// incircle of a regular polygon.
///
/// The incircle of a regular polygon is the largest circle that fits
/// entirely inside the polygon, touching each side exactly once.
/// Each panel is positioned tangent to this incircle, producing a
/// room layout that feels circular while still being polygonally constrained.
///
/// The incircle:
/// - Always exists for regular polygons
/// - Is centered at the polygon's incenter
/// - Has radius equal to the polygon's *apothem*
///
/// 🔗 https://www.mathopenref.com/polygonincircle.html
/// 🔗 https://www.mathopenref.com/polygoncentralangle.html
class IrregularConvexPolygonIncircleRoomGeometry: RoomGeometry {

    /// The number of sides of the regular polygon.(panels + 1 for door?)
    var numberOfSides: Double

    /// The length of a single side of the regular polygon.
    ///
    /// By definition, all sides of a regular polygon are equal in length.
    var sideLength: Double

    /// The radius of the polygon’s incircle.
    ///
    /// Also known as the *apothem*, this is the distance from the center of
    /// the polygon to the midpoint of any side. Panels are positioned
    /// tangent to this circle.
    var inradius: Double

    /// The central angle subtended by one side of the polygon.
    ///
    /// This is the angle between two adjacent vertices as measured
    /// from the center of the polygon. All central angles are equal.
    var centralAngle: Double

    /// The world-space offset applied to the entire room geometry.
    ///
    /// This defines where the center of the polygon is located in the scene.
    var roomOriginOffset: SIMD3<Double>

    /// The current state of the room's drag.
    ///
    /// Dragging updates an accumulated angular offset that shifts
    /// all panels around the incircle.
    var dragState: DragState = DragState()

    /// Private initializer for fully-specified polygon geometry.
    ///
    /// All geometric parameters must already be computed before calling
    /// this initializer. See the "convenience" inits.
    private init(
        numberOfSides: Double,
        sideLength: Double,
        inradius: Double,
        centralAngle: Double,
        roomOriginOffset: SIMD3<Double>
    ) {
        self.numberOfSides = numberOfSides
        self.sideLength = sideLength
        self.inradius = inradius
        self.centralAngle = centralAngle
        self.roomOriginOffset = roomOriginOffset
    }

    /// Computes the parametric (angular) position of a panel along the polygon.
    ///
    /// This value represents the panel’s index around the incircle,
    /// adjusted by any accumulated drag offset, and wrapped to stay
    /// within the polygon’s bounds.
    ///
    /// - Parameters:
    ///     - panel: The panel whose parametric position is requested.
    /// - Returns: A wrapped, continuous index representing angular placement.
    func parametricPosition(of panel: Panel) -> Double {

        let offset = dragState.accumulatedAzimuthOffset

        return (Double(panel.index) + offset)
            .truncatingRemainder(
                dividingBy: numberOfSides
            )

    }

    /// Maps a panel’s 1D parametric position into a 3D transform.
    ///
    /// This function:
    /// - Rotates the panel around the Y-axis
    /// - Translates it outward to lie tangent to the incircle
    /// - Centers it vertically based on panel height
    ///
    /// - Parameters:
    ///     - panel: The panel to position.
    /// - Returns: A `Transform` representing the panel’s world-space placement.
    func map1DTo3D(for panel: Panel) -> Transform {

        // SCALE
        let scale: SIMD3<Float> = [1, 1, 1]

        // ROTATION
        // Ø = angular rotation of panel around the circle
        let theta = -panel.parametricPosition * centralAngle
        let rotationAxis: SIMD3<Float> = [0, 1, 0]
        let rotation: simd_quatf = simd_quaternion(Float(theta), rotationAxis)
        // let rotation: simd_quatf = simd_quaternion(Float(theta) + .pi, rotationAxis)

        // TRANSLATION
        let angleAroundCircle = theta + normal90

        // Base vertical center of the panel
        let baseY = Double(panel.shape.height) / 2.0

        // Final 3D coordinates (@ panel's center of mass)
        let x = inradius * cos(angleAroundCircle) + roomOriginOffset.x
        let y = baseY + roomOriginOffset.y  // + 0.4
        let z = -(inradius * sin(angleAroundCircle)) + roomOriginOffset.z

        let translation: SIMD3<Float> = [Float(x), Float(y), Float(z)]

        return Transform(
            scale: scale,
            rotation: rotation,
            translation: translation
        )
    }

    /// Processes a drag gesture to rotate the room around its incircle.
    ///
    /// The drag is achieved via the dot product of movement and the geometry's line --> panels follow the line / drag moves the line.
    ///
    /// - Parameters:
    ///   - dragGesture: The drag gesture targeting a RealityKit entity.
    func processDragGesture(
        _ dragGesture: EntityTargetValue<DragGesture.Value>
    ) {
        let current = dragGesture.convert(
            dragGesture.location3D,
            from: .local, to: .scene
        )

        // On the first event, just record position and bail
        guard let previous = dragState.lastDragPosition else {
            dragState.lastDragPosition = current
            return
        }

        let movement = current - previous
        dragState.lastDragPosition = current

        let roomCenter = SIMD3<Float>(
            Float(roomOriginOffset.x), current.y, Float(roomOriginOffset.z)
        )
        let radial = current - roomCenter
        guard length(radial) > 0.0001 else { return }

        let tangent = normalize(SIMD3<Float>(-radial.z, 0, radial.x))
        let arcDelta = Double(dot(tangent, movement))

        dragState.accumulatedAzimuthOffset += (arcDelta / inradius) / centralAngle
    }

}

// MARK: Public initializers
extension IrregularConvexPolygonIncircleRoomGeometry {

    /// Creates geometry from a known side length.
    ///
    /// - Parameters:
    ///   - numberOfSides: The number of sides in the polygon.
    ///   - sideLength: The length of each side.
    ///   - roomOriginOffset: World-space center of the room.
    public convenience init(
        numberOfSides: Int,
        sideLength: Float,
        roomOriginOffset: SIMD3<Float> = [0, 0.4, 0]
    ) {

        let numberOfSides_d = Double(numberOfSides)

        let sideLength_d = Double(sideLength)

        let inradius_d = sideLength_d / (2 * tan(π / numberOfSides_d))

        let centralAngle_d = (2 * π) / numberOfSides_d

        let roomOriginOffset_d = SIMD3<Double>(roomOriginOffset)

        self.init(
            numberOfSides: numberOfSides_d,
            sideLength: sideLength_d,
            inradius: inradius_d,
            centralAngle: centralAngle_d,
            roomOriginOffset: roomOriginOffset_d
        )
    }

    /// Creates geometry from a known incircle radius.
    ///
    /// - Parameters:
    ///   - numberOfSides: The number of sides in the polygon.
    ///   - inradius: The radius of the incircle (apothem).
    ///   - roomOriginOffset: World-space center of the room.
    public convenience init(
        numberOfSides: Int,
        inradius: Float,
        roomOriginOffset: SIMD3<Float> = [0, 0.4, 0]
    ) {

        let numberOfSides_d = Double(numberOfSides)

        let inradius_d = Double(inradius)

        let sideLength_d = 2 * inradius_d * tan(π / numberOfSides_d)

        let centralAngle_d = (2 * π) / numberOfSides_d

        let roomOriginOffset_d = SIMD3<Double>(roomOriginOffset)

        self.init(
            numberOfSides: numberOfSides_d,
            sideLength: sideLength_d,
            inradius: inradius_d,
            centralAngle: centralAngle_d,
            roomOriginOffset: roomOriginOffset_d
        )
    }

    /// Creates geometry from the arc length of a central angle.
    ///
    /// This initializer is useful when spacing curved panels along
    /// a circular arc rather than reasoning directly in side lengths.
    ///
    /// - Parameters:
    ///   - numberOfSides: The number of sides in the polygon.
    ///   - centralAngleArcLength: Arc length corresponding to one panel.
    ///   - roomOriginOffset: World-space center of the room.
    public convenience init(
        numberOfSides: Int,
        centralAngleArcLength: Float,
        roomOriginOffset: SIMD3<Float> = [0, 0.4, 0]
    ) {
        let numberOfSides_d = Double(numberOfSides)

        let arcLength_d = Double(centralAngleArcLength)

        let inradius_d = (arcLength_d * numberOfSides_d) / (2 * π)

        let centralAngle_d = (2 * π) / numberOfSides_d

        let sideLength_d = 2 * inradius_d * tan(centralAngle_d / 2)

        let roomOriginOffset_d = SIMD3<Double>(roomOriginOffset)

        self.init(
            numberOfSides: numberOfSides_d,
            sideLength: sideLength_d,
            inradius: inradius_d,
            centralAngle: centralAngle_d,
            roomOriginOffset: roomOriginOffset_d
        )
    }

}
