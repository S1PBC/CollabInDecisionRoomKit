//
//  DragState.swift
//
//  Created by Ella Isgar on 12/9/25.
//

struct DragState {

    // azimuth = horizontal
    // inclination = vertical

    // DIRECTION
    /// Signed direction (+/-1) of horizontal drag (left/right)
    var azimuthDirection: Double = 0

    /// Signed direction (+/-1) of vertical drag (up/down)
    var inclinationDirection: Double = 0

    // VELOCITY FACTOR
    /// Scales azimuth shift (based off of drag velocity)
    var azimuthVelocityFactor: Double = 0

    /// Scales inclination shift (based off of drag velocity)
    var inclinationVelocityFactor: Double = 0

    // ACCUMULATED OFFSET
    /// Accumulated parametric shift around room's perimeter
    var accumulatedAzimuthOffset: Double = 0

    /// Accumulated vertical parametric shift
    var accumulatedInclinationOffset: Double = 0
    
    
    ///
    var lastDragPosition: SIMD3<Float>?

}
