//
//  CurvedRectangularPrism.swift
//
//  Created by Ella Isgar on 12/16/25.
//

import RealityKit

/// A plane that wraps around the Y-axis at a constant distance, forming a circular arc, that is evenly extruded from its front and back to form a curved rectangular prism.
///
/// NOTE: This plane is henceforth referred to as the "mid-plane" of the curved rectangular prism.
class CurvedRectangularPrism: PanelShape {

    /// Width (m) of panel's bounding box and equal to chord of panel's mid-plane curve.
    let width: Float

    /// Height (m) of the rectangular prism and equal to height (m) of panel's bounding box.
    let height: Float

    /// Depth (m) of panel's bounding box.
    let depth: Float
    
    /// Depth (m) of the curved rectangular prism
//    let panelDepth: Float

//
//    /// The central angle (radians) swept by the mid-plane along its circular arc.
//    ///
//    /// - NOTE: A larger angle produces a more curved panel.
//    var arcAngle: Float
//
//    /// The curved distance (m) along the mid-plane from one end to the other.
//    ///
//    /// Defined as: arcLength = radius x arcAngle.
//    var midArcLength: Float
//
//    /// The straight-line distance (m) between the two arc endpoints of the mid-plane.
//    ///
//    /// - NOTE: The chord always be shorter than the arcLength unless the arcAngle is zero.
//    var chord: Float
//
//    /// The radius (m) of the circle that the mid-plane lies on.
//    var midRadius: Float
//
//    /// The radius (m) of the circle that the curved rectangular prism's inner plane/surface lies on.
//    var inRadius: Float
//
//    /// The radius (m) of the circle that the curved rectangular prism's outer plane/surface lies on.
//    var outRadius: Float
    
    var radiusOfCurvature: Float
    
    /// How many times the panel's mesh is subdivided along the X-Axis for a smooth curve.
    var quality: Int = 4

    /// How the corners of the panel are rounded.
    var cornerRounding: PanelCornerRounding

    /// Cached mesh to avoid uneccessarily regenerating
    var meshResource: MeshResource? = nil

    /// Cached collision shape to avoid uneccessarily regenerating
    var collisionShapeResource: ShapeResource? = nil

    /// Private initializer for fully-specified curved rectangular prism.
    ///
    /// All  parameters must already be computed before calling this
    /// initializer. See the "convenience" inits.
    // private init(
    init(
        width: Float,
        height: Float,
        depth: Float,
//        thickness: Float,
//        arcAngle: Float,
//        midArcLength: Float,
//        chord: Float,
//        midRadius: Float,
//        inRadius: Float,
//        outRadius: Float,
        radiusOfCurvature: Float,
        cornerRounding: PanelCornerRounding = .uniform()
    ) {
        self.width = width
        self.depth = depth
        self.height = height
//        self.thickness = thickness
//        self.arcAngle = arcAngle
//        self.midArcLength = midArcLength
//        self.chord = chord
//        self.midRadius = midRadius
//        self.inRadius = inRadius
//        self.outRadius = outRadius
        self.radiusOfCurvature = radiusOfCurvature
        self.cornerRounding = cornerRounding
    }

    //    func generateMeshResource() -> MeshResource {
    //        return MeshResource.generateCurvedBox(
    //            arcAngle: arcAngle,
    //            midRadius: midRadius,
    //            height: height,
    //            thickness: thickness
    //        )
    //    }

    @MainActor
    func generateMeshResource() -> MeshResource {
        guard meshResource == nil else { return meshResource! }

        let (majorCornerRadius, minorCornerRadius) = cornerRounding.getRadii(
            width: width,
            height: height,
            depth: depth
        )

        if case .majorMinor(_, _) = self.cornerRounding {
            meshResource = MeshResource.generateBox(
                size: simd_float3(width, height, depth),
                majorCornerRadius: majorCornerRadius,
                minorCornerRadius: minorCornerRadius
            )
        } else {
            meshResource = MeshResource.generateBox(
                width: width,
                height: height,
                depth: depth,
                cornerRadius: majorCornerRadius
            )
        }

        meshResource = meshResource?.withTransformedDescriptors { descriptor in
            var descriptor = descriptor

            // Subdivide for a smooth curve

            descriptor.subdivideAlongXAxis(
                iterations: self.quality,
                minFaceXWidth: 0.1 / Float(self.quality)
            )

            if case .majorMinor(_, _) = self.cornerRounding {
                // Project UVs to fix broken UVs
                descriptor.xyProjectUVs(width: self.width, height: self.height)
            }

            // Curve (by adding curvature to the subdivided panel mesh)
            descriptor.curveAboutY(
                curveRadius: self.radiusOfCurvature,
                width: self.width
            )

            return descriptor
        }

        return meshResource!

    }

    func generateCollisionShapeResource() async -> ShapeResource {

        guard collisionShapeResource == nil else {
            return collisionShapeResource!
        }

        if let ret =
            (try? await ShapeResource.generateStaticMesh(
                from: generateMeshResource()
            ))
        {
            logger.log("Curved shape resource successfully generated.")
            collisionShapeResource = ret
        } else {
            logger.error("Curved shape resource FAILED to generate.")
            collisionShapeResource = await ShapeResource.generateBox(
                width: width,
                height: height,
                depth: depth
            )
        }

        return collisionShapeResource!
    }
}

// MARK: Public initializers
extension CurvedRectangularPrism {

//    /// - Parameters:
//    ///     - height: The height (m) of the curved rectangular prism.
//    ///     - thickness: The thickness (m), aka depth, of the curved rectangular prism.
//    ///     - midArcLength: The curved distance (m) along the mid-plane from one end to the other.
//    ///     - midRadius: The radius (m) of the circle that the mid-plane lies on.
//    ///     - cornerRadius: of each corner's circular arc.
//    public convenience init(
//        height: Float,
//        thickness: Float,
//        midArcLength: Float,
//        midRadius: Float,
//        cornerRounding: PanelCornerRounding = .none
//    ) {
//        let inRadius = midRadius - thickness / 2
//        let outRadius = midRadius + thickness / 2
//
//        let arcAngle = midArcLength / midRadius
//
//        let chord = 2 * midRadius * sin(arcAngle / 2)
//
//        // Bounding box dimensions
//        let width: Float
//        let depth: Float
//
//        if Double(arcAngle) <= π {
//            // the outer arc never crosses into negative X
//            width = outRadius - outRadius * cos(arcAngle / 2)
//            depth = 2 * outRadius * sin(arcAngle / 2)
//        } else {
//            width = 2 * outRadius
//            depth = 2 * outRadius
//        }
//
//        //        print(
//        //            """
//        //            width: \(width),
//        //            height: \(height),
//        //            thickness: \(thickness),
//        //            cornerRadius: \(cornerRadius)
//        //            """
//        //        )
//
//        self.init(
//            width: width,
//            depth: depth,
//            height: height,
//            thickness: thickness,
//            arcAngle: arcAngle,
//            midArcLength: midArcLength,
//            chord: chord,
//            midRadius: midRadius,
//            inRadius: inRadius,
//            outRadius: outRadius,
//            cornerRounding: cornerRounding
//        )
//    }
    
    /// - Parameters:
    ///     - height: The height (m) of the curved rectangular prism.
    ///     - thickness: The thickness (m), aka depth, of the curved rectangular prism.
    ///     - midArcLength: The curved distance (m) along the mid-plane from one end to the other.
    ///     - midRadius: The radius (m) of the circle that the mid-plane lies on.
    ///     - cornerRadius: of each corner's circular arc.
//    public convenience init(
//        width: Float,
//        height: Float,
//        depth: Float,
//        radiusOfCurvature: Float = .infinity,
//        cornerRounding: PanelCornerRounding = .none
//    ) {
//        let inRadius = midRadius - thickness / 2
//        let outRadius = midRadius + thickness / 2
//
//        let arcAngle = midArcLength / midRadius
//
//        let chord = 2 * midRadius * sin(arcAngle / 2)
//
//        // Bounding box dimensions
//        let width: Float
//        let depth: Float
//
//        if Double(arcAngle) <= π {
//            // the outer arc never crosses into negative X
//            width = outRadius - outRadius * cos(arcAngle / 2)
//            depth = 2 * outRadius * sin(arcAngle / 2)
//        } else {
//            width = 2 * outRadius
//            depth = 2 * outRadius
//        }

        //        print(
        //            """
        //            width: \(width),
        //            height: \(height),
        //            thickness: \(thickness),
        //            cornerRadius: \(cornerRadius)
        //            """
        //        )

//        self.init(
//            width: width,
//            height: height,
//            depth: depth,
//            radiusOfCurvature: radiusOfCurvature,
//            cornerRounding: cornerRounding
//        )
//    }
}
