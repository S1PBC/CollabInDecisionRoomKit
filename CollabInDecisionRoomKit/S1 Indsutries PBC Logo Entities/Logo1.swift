//
//  Logo1.swift
//  Rooms
//
//  Created by Ella Isgar on 1/23/26.
//

import RealityKit
import SwiftUI

/// Generates a 3D S1 Logo entity by displaying the S1 emblem (white background) as
/// the texture/material of a cylinder (0.1m tall x 0.5 m wide) placed 4m above the origin.
public func createS1IndustriesPBCLogoEntity1() -> Entity {

    let mesh = MeshResource.generateCylinder(
        height: 0.1,
        radius: 0.5
    )

    let material = UIImage(named: "S1Emblem_WhiteBackground.png")?
        .toTextureResource()?
        .toRealityKitMaterial()

    /*
    var cgImage = textureImage?.cgImage
    var texture = try TextureResource(
        image: cgImage!,
        options: TextureResource.CreateOptions.init(semantic: nil)
    )
    var baseColor = MaterialParameters.Texture(texture)
    logoMaterial.baseColor = PhysicallyBasedMaterial.BaseColor(
        texture: baseColor
    )
     */

    let entity = ModelEntity(
        mesh: mesh,
        materials: [material!]
    )
    entity.name = "S1 Industries PBC Logo #1"
    
    // Move the logo 4m "up"
    // NOTE: The default behavior of this logo is to appear 4m
    //       above the origin of the room.
    entity.transform = Transform(translation: .init(0, 4, 0))

    return entity
}
