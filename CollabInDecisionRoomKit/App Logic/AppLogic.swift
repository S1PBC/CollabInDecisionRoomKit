//
//  AppLogic.swift
//
//  Created by Ella Isgar on 12/17/25.
//

import RealityKit
import SwiftUI

@Observable
class AppLogic {

    /// This RealityKit entity is the root of all other entities in the app.
    var entity: Entity

    /// A controller of the app's rooms including the individual lifecycle of each room and their actual ``Room`` object.
    var controllerOfRooms: ControllerOfRooms

    // MARK: P.E.A.R
    /// The Perception Engine Augmented Reality (P.E.A.R.) that controls how the ``controllerOfRooms`` is perceived.
    var pear: PEAR

    // MARK: Immersive Space
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    
    /// The current state of the immersive space.
    var immersiveSpaceState = ImmersiveSpaceState.closed

    /// The immersive space's id used to identify and open it.
    var immersiveSpaceID = "Free Shavacado 🥑"

    init() {

        let entity = Entity()
        entity.name = "App Entity"
        
        let controllerOfRooms = ControllerOfRooms()
        entity.addChild(controllerOfRooms.entity)
        
        let pear = PEAR(controllerOfRooms)

        self.entity = entity
        self.controllerOfRooms = controllerOfRooms
        self.pear = pear
    }

}
