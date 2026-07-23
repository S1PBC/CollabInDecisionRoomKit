//
//  RectangularPrism.swift
//
//  Created by Ella Isgar on 12/16/25.
//

import Foundation
import MetalKit
import ModelIO
import RealityKit

class RectangularPrism: PanelShape {

    /// Width (m) of the rectangular prism and equal to width (m) of panel's bounding box.
    let width: Float

    /// Height (m) of the rectangular prism and equal to height (m) of panel's bounding box.
    let height: Float

    /// Depth (m) of the rectangular prism and equal to depth (m) of panel's bounding box.
    let depth: Float
    
    /// How the corners of the panel are rounded.
    var cornerRounding: PanelCornerRounding

    /// Cached mesh to avoid uneccessarily regenerating
    var meshResource: MeshResource? = nil

    /// Cached collision shape to avoid uneccessarily regenerating
    var collisionShapeResource: ShapeResource? = nil

    /// - Parameters:
    ///     - width: of rectangular prism in meters.
    ///     - height: of rectangular prism in meters.
    ///     - depth: of rectangular prism in meters.
    ///     - cornerRounding: method to determine how every corner of panel curved.
    init(
        width: Float,
        height: Float,
        depth: Float,
        cornerRounding: PanelCornerRounding
    ) {
        self.width = width
        self.height = height
        self.depth = depth
        self.cornerRounding = cornerRounding
    }

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
            ).withTransformedDescriptors { descriptor in
                var descriptor = descriptor

                // Project UVs to fix broken UVs
                descriptor.xyProjectUVs(width: self.width, height: self.height)

                return descriptor
            }
        } else {
            meshResource = MeshResource.generateBox(
                width: width,
                height: height,
                depth: depth,
                cornerRadius: majorCornerRadius
            )
        }

        return meshResource!

    }

    func generateCollisionShapeResource() -> ShapeResource {

        guard collisionShapeResource == nil else {
            return collisionShapeResource!
        }

        return ShapeResource.generateBox(
            width: width,
            height: height,
            depth: depth
        )
    }
}

extension RectangularPrism {

    var debugDescription: String {
        """
        width: \(width)
        height: \(height)
        depth: \(depth)
        cornerRounding: \(cornerRounding)
        """
    }

}
