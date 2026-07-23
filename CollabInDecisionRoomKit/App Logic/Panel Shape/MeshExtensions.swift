//
//  MeshExtensions.swift
//
//  Created by Ethan Medeiros on 3/26/26 in RoomCollaborationDemo.
//

import RealityKit
import simd

// This file provides helper functions for modular, atomic manipulation of MeshDescriptors from MeshResources

internal extension MeshResource {
    /**
     Converts the MeshResource's parts to descriptors, allows you to transform those as you please, then reconstructs a MeshResource.
     
     Descriptors allow for advanced vertex & uv manipulations.
     */
    func withTransformedDescriptors(_ transformDescriptor: @escaping (MeshDescriptor) -> MeshDescriptor) -> MeshResource {
        var transformedDescriptors: [MeshDescriptor] = []
        for model in self.contents.models {
            for part in model.parts {
                transformedDescriptors.append(transformDescriptor(MeshDescriptor(from: part)))
            }
        }
        return try! MeshResource.generate(from: transformedDescriptors)
    }
}

internal extension MeshDescriptor {
    /// Create a mesh descriptor from the mesh resource's first part.
    init(from part: MeshResource.Part) {
        self.init()
        positions = part.positions
        normals = part.normals
        tangents = part.tangents
        textureCoordinates = part.textureCoordinates
        
        if let indices = part.triangleIndices {
            self.primitives = .triangles(indices.elements)
        }
    }
    
    /**
     Regenerate all UVs based on their X and Y coordinates.
     
     width, height: The width (x) and height (y) in mesh-space of the texture
     center: (default: .zero) The center (x,y) in mesh-space of the texture
     autoMirror: (default: true) If true, any faces on the negative-z side will be horizontally mirrored
     */
    mutating func xyProjectUVs(width: Float, height: Float, center: SIMD2<Float> = .zero, autoMirror: Bool = true) {
        var textureCoordinates : [simd_float2] = []
        for i in 0..<self.positions.count {
            let pos = self.positions.elements[i]
            var uv: SIMD2<Float> = .init(
                ((pos.x - center.x) / width ) - 0.5,
                ((pos.y - center.y) / height) - 0.5
            )
            // If on the negative z side, mirror the UVs
            // If normals are nil, use the position's z. Else, use the normal's z.
            if autoMirror && (self.normals == nil ? pos.z < 0 : (self.normals?.elements[i].z ?? 0 < 0)) {
                uv.x = 1 - uv.x
            }
            textureCoordinates.append(uv)
        }
        self.textureCoordinates = .init(textureCoordinates)
    }
    
    /**
     Curves a mesh's X and Z coordinates around an imaginary circle centered at Y=curve radius.
     Perform this on a flat panel for a result similar to a curved PC monitor.
     
     Note that this does not add geometry, so it is likely desirable to subdivide first.
     
     curveRadius: Radius of curvature. Larger values = less curved.
     width: Width, on the X-axis, of the input mesh. The output will have an arc-length of this value to retain width.
     */
    mutating func curveAboutY(curveRadius: Float, width: Float) {
        // Calculate width out as a number of radians
        let curveCircumference = .pi * 2 * curveRadius
        let widthAngularFraction = width / Float(curveCircumference)
        let angularWidthOutRadians = widthAngularFraction * .pi * 2
        
        var transformedPositions: [SIMD3<Float>] = positions.elements
        // Transform x & z coordinates to angle and distance along a circle
        for i in 0..<positions.count {
            let p = positions.elements[i]
            let dist = curveRadius + p.z
            let angle = p.x / width * angularWidthOutRadians

            transformedPositions[i].x = dist * sin(angle)
            transformedPositions[i].z = dist * cos(angle)
            
            // subtract radius from so that the panel mesh's origin is the center of the panel,
            // rather than the center of the imaginary circle
            transformedPositions[i].z -= curveRadius
        }
        // Replace the positions buffer with the new one
        positions = .init(transformedPositions)
        
    }
        
    /**
     Subdivide a mesh along the X-Axis only.
     Each iteration splits faces into two.

     Faces with an x-width below minFaceXWidth won't be touched.
     Nonzero minFaceXWidth values can lead to holes forming on diagonal edges of complex geometry.
     
     ***This method will clear all UVs and tangents but will preserve normals by interpolation
     */
    mutating func subdivideAlongXAxis(
        iterations: Int = 1,
        minFaceXWidth: Float = 0.0,
    ) {
        for _ in 0..<iterations {
            self.subdivideAlongXAxis(minFaceXWidth: minFaceXWidth)
        }
    }

    /// Performs a single subdivision step on the whole mesh, along the x-axis only.
    private mutating func subdivideAlongXAxis(
        minFaceXWidth: Float = 0.0,
    ) {
        struct Edge: Hashable {
            let a: UInt32
            let b: UInt32

            init(_ v0: UInt32, _ v1: UInt32) {
                if v0 < v1 {
                    a = v0
                    b = v1
                } else {
                    a = v1
                    b = v0
                }
            }
        }

        var newPositions = positions.elements
        var newNormals = normals?.elements
        var newTextureCoordinates = textureCoordinates?.elements
        var midpointCache = [Edge: UInt32]()
        var newIndices = [UInt32]()

        let threshold = max(0, minFaceXWidth)

        func midpointIndex(for edge: Edge, between first: UInt32, and second: UInt32) -> UInt32 {
            if let cached = midpointCache[edge] {
                return cached
            }

            let firstPosition = newPositions[Int(first)]
            let secondPosition = newPositions[Int(second)]

            if firstPosition.x == secondPosition.x {
                midpointCache[edge] = first
                return first
            }

            let midpointX = (firstPosition.x + secondPosition.x) * 0.5
            let midpointY = (firstPosition.y + secondPosition.y) * 0.5
            let midpointZ = (firstPosition.z + secondPosition.z) * 0.5

            let midpoint = SIMD3<Float>(
                midpointX,
                midpointY,
                midpointZ
            )

            let newIndex = UInt32(newPositions.count)
            newPositions.append(midpoint)

            if let firstNormal = newNormals?[Int(first)],
               let secondNormal = newNormals?[Int(second)] {
                let summedNormals = firstNormal + secondNormal
                let normalLength = simd_length(summedNormals)
                let interpolatedNormal = normalLength > 0 ? summedNormals / normalLength : firstNormal
                newNormals?.append(interpolatedNormal)
            }
            if let firstUV = newTextureCoordinates?[Int(first)],
               let secondUV = newTextureCoordinates?[Int(second)] {
                let midpointUV = (firstUV + secondUV) * 0.5
                newTextureCoordinates?.append(midpointUV)
            }

            midpointCache[edge] = newIndex
            return newIndex
        }

        if case let .triangles(indices) = primitives {
            let triangleIndices = indices
            let triangleCount = indices.count / 3
            for tri in 0..<triangleCount {
                let base = tri * 3
                let v0 = triangleIndices[base]
                let v1 = triangleIndices[base + 1]
                let v2 = triangleIndices[base + 2]

                let p0 = newPositions[Int(v0)]
                let p1 = newPositions[Int(v1)]
                let p2 = newPositions[Int(v2)]

                let maxX = max(p0.x, max(p1.x, p2.x))
                let minX = min(p0.x, min(p1.x, p2.x))
                let xRange = maxX - minX
                if xRange < threshold {
                    newIndices += [v0, v1, v2]
                    continue
                }

                let e01 = Edge(v0, v1)
                let e12 = Edge(v1, v2)
                let e02 = Edge(v0, v2)

                let m01 = midpointIndex(for: e01, between: v0, and: v1)
                let m12 = midpointIndex(for: e12, between: v1, and: v2)
                let m02 = midpointIndex(for: e02, between: v0, and: v2)

                newIndices += [
                    v0, m01, m02,
                    m01, v1, m12,
                    m02, m12, v2,
                    m01, m12, m02
                ]
            }
            positions = .init(newPositions)
            primitives = .triangles(newIndices)
            
            // Clear per-vertex and per-face values now that we've changed the amount of both
            if let updatedTextureCoordinates = newTextureCoordinates {
                textureCoordinates = .init(updatedTextureCoordinates)
            } else {
                textureCoordinates = nil
            }
            if let updatedNormals = newNormals {
                normals = .init(updatedNormals)
            } else {
                normals = nil
            }
            tangents = nil
        } else {
            logger.warning("Cannot subdivide non-triangle meshes along the X axis.")
        }
    }

    /**
     Offset all positions by a uniform vector
     */
    mutating func translate(by offset: SIMD3<Float>) {
        positions = .init(positions.map({ pos in pos + offset }))
    }
    
    /**
     Transform the mesh
     */
    mutating func transform(by transform: Transform) {
        let matrix = transform.matrix
        positions = .init(positions.map { pos in
            let transformed = matrix * SIMD4<Float>(pos, 1)
            return SIMD3<Float>(transformed.x, transformed.y, transformed.z)
        })
        if let normalsBuffer = normals {
            let rotatedNormals = normalsBuffer.map { normal in
                transform.rotation.act(normal)
            }
            normals = .init(rotatedNormals)
        }
        if let tangentsBuffer = tangents {
            let rotatedTangents = tangentsBuffer.map { tangent in
                transform.rotation.act(tangent)
            }
            tangents = .init(rotatedTangents)
        }
    }

}
