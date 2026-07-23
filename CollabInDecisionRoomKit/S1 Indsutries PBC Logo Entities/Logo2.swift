//
//  Logo2.swift
//  Rooms
//
//  Created by Ella Isgar on 1/23/26.
//

import RealityKit
import SwiftUI

/// Generates a 3D S1 Logo entity by displaying in front of a transparent, rounded
/// rectangular base: (1) the S1 emblem (transparent background) all the way on
/// the left and (2) text ("Rendered by \n S1 Industries PBC \n 2025) centered within
/// the rest of the space available on the right side of the base.
public func createS1IndustriesPBCLogoEntity2() -> Entity {

    /// The base of the logo aka a transparent, rounded rectangle.
    let baseEntity: ModelEntity = {
        let mesh = MeshResource.generatePlane(
            width: 1.75,
            height: 0.6,
            cornerRadius: 1
        )

        var material = PhysicallyBasedMaterial()

        material.clearcoat = .init(floatLiteral: 1.0)

        material.baseColor = .init(
            tint: UIColor(cgColor: CGColor(gray: 1.0, alpha: 0.01))
        )

        material.emissiveIntensity = 10000

        let entity = ModelEntity(
            mesh: mesh,
            materials: [material]
        )

        entity.name = "Base"

        entity.components.set(
            OpacityComponent(opacity: 0.25)
        )

        return entity
    }()

    /// The S1 Industries PBC emblem (transparent background).
    let logoEntity: ModelEntity = {
        let mesh = MeshResource.generatePlane(
            width: 1,
            height: 1,
            cornerRadius: 0.5
        )

        let texture = UIImage(named: "S1Emblem_TransparentBackground.png")?
            .toTextureResource()

        var material = PhysicallyBasedMaterial()

        material.baseColor = PhysicallyBasedMaterial.BaseColor(
            texture: MaterialParameters.Texture(texture!)
        )

        material.emissiveColor = .init(
            texture: MaterialParameters.Texture(texture!)
        )

        material.emissiveIntensity = 0.0

        material.blending = .transparent(opacity: 1.0)

        let entity = ModelEntity(
            mesh: mesh,
            materials: [material]
        )
        entity.name = "Emblem"

        return entity
    }()

    /// Text label of the logo.
    let textEntity: ModelEntity = {

        let mesh = MeshResource.generateText(
            "Rendered by \nS1 Industries PBC \n2026",
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.08),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )

        let material = UnlitMaterial(color: .black)

        let entity = ModelEntity(
            mesh: mesh,
            materials: [material]
        )
        entity.name = "Text"

        return entity
    }()

    let entity = Entity()
    entity.name = "S1 Industries PBC Logo #2"

    entity.addChild(textEntity)
    entity.addChild(logoEntity)
    entity.addChild(baseEntity)
    
    textEntity.move(
        to: Transform(translation: .init(-0.1, 2.85, -2.5)),
        relativeTo: baseEntity
    )

    logoEntity.move(
        to: Transform(translation: SIMD3(-0.55, 2.975, -2.49)),
        relativeTo: baseEntity
    )

    // NOTE: The default behavior of this logo is to appear 3m above the ground /
    //       the origin of the room and appear (to the user) 2.5m in front of the
    //       room's origin / -2.5m from the x origin of the room.
    baseEntity.move(
        to: Transform(translation: .init(0, 3, -2.5)),
        relativeTo: nil
    )

    /*
     Rendering order:
     1. Base Entity
     2. Logo Entity (+ also technically should do Text Entity)
     */
    let group = ModelSortGroup()
    logoEntity.components.set(
        ModelSortGroupComponent(group: group, order: 2)
    )
    baseEntity.components.set(
        ModelSortGroupComponent(group: group, order: 1)
    )

    return entity

}
