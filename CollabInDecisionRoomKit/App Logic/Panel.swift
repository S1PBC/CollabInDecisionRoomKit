//
//  Panel.swift
//
//  Created by Ella Isgar on 12/11/25.
//

import Foundation
import RealityKit

class Panel: Identifiable {

    let id = UUID()

    let index: Int

    let shape: PanelShape

    var opacity: Float = 1  // 1 = fully opaque, 0 = completely transparent
    var isOpaque: Bool {
        didSet {
            setOpacity()
        }
    }

    let materialManager: MaterialManager

    var attachmentsManager: AttachmentsManager

    var parametricPosition: Double

    var entity: Entity

    var modelEntity: ModelEntity

    var bindings: [RoomBinding] = [] {
        didSet {
            if let binding = self.bindings.first(where: {
                $0.intendedAction.isSameCase(as: .toggle_panel_transparency(false))
            }),
                case .toggle(let value) = binding.initialState,
                value != isOpaque
            {
                logger.log("initial opacity = \(value), \(opacity)")
                self.isOpaque = value
            }
        }
    }

    init(
        index: Int,
        shape: PanelShape,
        opacity: Float = 1,
        materialManager: MaterialManager,
        attachments: [RoomAttachment] = []
    ) {

        self.index = index

        self.shape = shape

        self.opacity = opacity
        self.isOpaque = opacity == 1

        self.materialManager = materialManager

        self.attachmentsManager = AttachmentsManager(attachments)

        self.parametricPosition = 0

        self.entity = Entity()
        self.modelEntity = ModelEntity()

        self.observeCORCommands()
    }

    func observeCORCommands() {
        NotificationCenter.default.addObserver(
                forName: .controlStateUpdated,
                object: nil,
                queue: nil
            ) { [weak self] notification in
                guard let self,
                      let update = notification.object as? RoomControlStateUpdate,
                      let bindingn = self.bindings.first(where: {
                          $0.control == update.source &&
                          $0.intendedAction.isSameCase(as: .toggle_panel_transparency(false))
                      }),
                      case .toggle(let value) = update.state
                else { return }

                self.isOpaque = value
            }
    }

    func addAttachment(_ attachment: RoomAttachment) {
        attachmentsManager.add(attachment)
    }

    func teardownEntity() {

        // Attachments
        self.attachmentsManager.entity.isEnabled = false

        // ModelEntity
        self.modelEntity.removeFromParent(preservingWorldTransform: true)

        // Entity
        self.entity.removeFromParent()
    }

    @MainActor
    func setupEntity() async {

        // Entity
        let entity = Entity()
        entity.name = "Panel #\(index) Entity"
        self.entity = entity

        // ModelEntity
        let modelEntity = ModelEntity(
            mesh: shape.generateMeshResource(),
            materials: [materialManager.material],
            collisionShape: await shape.generateCollisionShapeResource(),
            mass: 0
        )
        modelEntity.name = "Panel #\(index) ModelEntity"
        self.modelEntity = modelEntity
        setModelEntityComponents()

        self.entity.addChild(modelEntity)

        // Attachments
        attachmentsManager.entity.isEnabled = true
        self.entity.addChild(attachmentsManager.entity)
        
//        attachmentsManager.entity.scale = SIMD3<Float>(repeating: 5.0)

        //        for attachmentsManager in entity.children {
        //
        //            logger.log("\(attachmentsManager.name) - \(attachmentsManager.isEnabled) - \(attachmentsManager.children.count) - \(attachmentsManager.components.count)")
        //
        //        }

    }

    func setModelEntityComponents() {

        // Set up the entity for input
        modelEntity.components.set(
            InputTargetComponent(allowedInputTypes: .all)
        )

        modelEntity.components.set(HoverEffectComponent())

        modelEntity.generateCollisionShapes(recursive: true)

        modelEntity.components.set(
            GroundingShadowComponent(
                castsShadow: true,
                receivesShadow: false,
                fadeBehaviorNearPhysicalObjects: .fade
            )
        )

        if !isOpaque {
            setOpacity()
        }

    }

    func setOpacity() {
        let opacity = isOpaque ? 1 : opacity
        modelEntity.components[OpacityComponent.self] = .init(
            opacity: opacity
        )
        logger.log("setting opacity to \(opacity)")
    }

}

//init(_ c: DefaultPanelConfiguration) {
//
//    self.index = c.index
//
//    self.shape = c.shape.get()
//
//    self.materialManager = c.materialManager.get()
//
//    self.entity = Entity()
//
//    self.modelEntity = ModelEntity()
//
//    self.parametricPosition = 0
//}
