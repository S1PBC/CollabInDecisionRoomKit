//
//  RoomGeometry+Debug.swift
//  Rooms
//
//  Created by Ella Isgar on 2/25/26.
//

import RealityKit
import SwiftUI

extension RoomGeometry {

    /// Spawns a small colored sphere at each panel's computed 3D position.
    /// Call this from ImmersiveView after placePanels() to visualize placement.
    ///
    /// - Parameters:
    ///   - panels: The panels to visualize.
    ///   - radius: Sphere radius in meters. Default 0.03 (3cm).
    @MainActor
    func addDebugEntities(
        for panels: [Panel],
        radius: Float = 0.03
    ) {
        // Remove old debug entities from panel entities directly
        for panel in panels {
            panel.entity.children
                .filter { $0.name.hasPrefix("debug_") }
                .forEach { $0.removeFromParent() }
        }

        for panel in panels {
            let color = debugColor(for: panel.index)

            let mesh = MeshResource.generateSphere(radius: radius)
            let material = SimpleMaterial(color: color, isMetallic: false)
            let entity = ModelEntity(mesh: mesh, materials: [material])
            entity.name = "debug_panel_\(panel.index)"

            // Position at origin relative to panel — the panel entity's
            // own transform already places it in the right world position
            entity.position = [0, 0, 0]

            let label = makeDebugLabel(
                text: "\(panel.index)\n(\(String(format: "%.2f", panel.parametricPosition)))",
                color: UIColor.black // color
            )
            label.transform = Transform(
                scale: [1, 1, 1],
                rotation: simd_quatf(angle: .pi, axis: [0, 1, 0]),
                translation: [0, radius * 2.5, -(radius * 2.5 + 0.1)]
            )
            entity.addChild(label)

            // 👇 Child of panel entity, not room entity
            panel.entity.addChild(entity)
        }
    }

    /// Removes all debug entities from a parent.
    @MainActor
    func removeDebugEntities(from panels: [Panel]) {
        for panel in panels {
            panel.entity.children
                .filter { $0.name.hasPrefix("debug_") }
                .forEach { $0.removeFromParent() }
        }
    }

    // MARK: - Helpers

    private func debugColor(for index: Int) -> UIColor {
        let palette: [UIColor] = [
            .systemRed, .systemOrange, .systemYellow,
            .systemGreen, .systemCyan, .systemBlue,
            .systemPurple, .systemPink, .systemMint
        ]
        return palette[index % palette.count]
    }

    private func makeDebugLabel(text: String, color: UIColor) -> Entity {
        let container = Entity()
        container.name = "debug_label"

        let lines = text.split(separator: "\n").map(String.init)
        let fontSize: Float = 0.02
        let lineHeight: Float = 0.025
        let padding: Float = 0.008

        // Approximate text width based on character count of longest line
        let longestLine = lines.map(\.count).max() ?? 1
        let textWidth: Float = Float(longestLine) * fontSize * 0.6
        let textHeight: Float = lineHeight * Float(lines.count)

        // Background — centered at container origin
        let bgMesh = MeshResource.generatePlane(
            width: textWidth + padding * 2,
            height: textHeight + padding * 2
        )
        var bgMaterial = UnlitMaterial()
        bgMaterial.color = .init(tint: .white)
        let bg = ModelEntity(mesh: bgMesh, materials: [bgMaterial])
        bg.position = [textWidth / 2, -textHeight / 2 + lineHeight / 2, -0.001]
        container.addChild(bg)

        // Text lines — stacked downward from y=0
        for (i, line) in lines.enumerated() {
            let mesh = MeshResource.generateText(
                line,
                extrusionDepth: 0.001,
                font: .systemFont(ofSize: CGFloat(fontSize)),
                containerFrame: .zero,
                alignment: .left,
                lineBreakMode: .byWordWrapping
            )
            var material = UnlitMaterial()
            material.color = .init(tint: color)
            let entity = ModelEntity(mesh: mesh, materials: [material])
            entity.position = [0, -Float(i) * lineHeight, 0]
            container.addChild(entity)
        }

        return container
    }
}
