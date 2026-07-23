//
//  PanelShape.swift
//
//  Created by Ella Isgar on 12/8/25.
//

import RealityKit

/// The 3D geometric shape of a ``Panel``.
///
///          Y (height)
///          ↑
///          |     +──────+
///          |    /      /|
///          |   +──────+ |
///          |   |   ?  | +
///          |   |      |/
///          |   +──────+
///          +────────────→ X (width)
///         /
///        /
///        Z (depth)
///
///        ? = The actual 3D shape of the panel is defined in classes that implement PanelShape.
protocol PanelShape {
    
    /// The width of the bounding box, in meters, that fully encapsulates the panel's 3D shape.
    var width: Float { get }
    
    /// The height of the bounding box, in meters, that fully encapsulates the panel's 3D shape.
    var height: Float { get }
    
    /// The depth of the bounding box, in meters, that fully encapsulates the panel's 3D shape.
    var depth: Float { get }
    
    /// Cached mesh to avoid unneccessarily regenerating
    var meshResource: MeshResource? { get }
    
    /// Cached collision shape to avoid unneccessarily regenerating
    var collisionShapeResource: ShapeResource? { get }

    /// Generates a mesh, aka the visible geometric shape, of the panel.
    @MainActor
    func generateMeshResource() -> MeshResource
    
    /// Generates a shape representing the outer dimensions of the panel's 3D body for purposes of collision detection.
    func generateCollisionShapeResource() async -> ShapeResource
}
