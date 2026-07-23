//
//  ImmersiveView.swift
//
//  Created by Luis Perez-Breva on 2/13/24.
//

import ARKit
import Combine
import RealityKit
import SwiftUI
import GroupActivities

@available(visionOS 2.0, *)
/// The 3D RealityKit-based scene. The root entity of this scene is the app (aka AppLogic's) entity.
struct ImmersiveView: View {

    @Environment(AppLogic.self) var app
    @Environment(COR.self) var cor
    @Environment(PEAR.self) var pear

    var body: some View {

        RealityView { content, attachments in

            content.add(app.entity)

            // Add all possible attachments to the scene.

            for manager in cor.getAllAttachmentsManagers() {

                for attachment in manager.getAllAttachments() {

                    guard
                        let entity = attachments.entity(
                            for: attachment.id
                        )
                    else { continue }

                    entity.name = "\(attachment.id) Entity"

                    entity.position = attachment.position
                    entity.orientation = attachment.orientation
                    
                    entity.scale = attachment.scale

                    manager.entity.addChild(entity)

                }
            }

        } update: { content, attachment in

            // Fires after RealityKit processes each scene update
            if let completion = cor.onRoomPlacementComplete {
                cor.onRoomPlacementComplete = nil  // clear before calling to avoid re-entry
                completion()
            }

        } attachments: {
            // Attachments are views that can be positioned at specific locations relative to your RealityKit entities.

            // All possible attachments must be created when the scene is first created.
            ForEach(cor.getAllAttachments()) { attachment in

                Attachment(id: attachment.id) {
                    AttachmentView(attachment)
                        .frame(
                            width: attachment.frameWidth,
                            height: attachment.frameHeight
                        )
                }

            }

        }
        .task {
            cor.startARKitSession()
        }
        .task {
            await cor.startHeadTrackingLoop()
        }
        .task {
            // P.E.A.R. - Shareplay
            pear.sharePlayManager.registerRoomsGroupActivity()

            for await session in RoomsGroupActivity.sessions() {
                await pear.sharePlayManager.configureGroupSession(
                    session: session
                )
            }
        }
        .gesture(
            DragGesture(minimumDistance: 15)
                .targetedToAnyEntity()
                .onChanged { dragGestureValue in
                    cor.dragRoom(with: dragGestureValue)
                }
                .onEnded { _ in
                    cor.resetLastDragPosition()
                }
        )
        .onAppear {
            app.immersiveSpaceState = .open
            logger.log("Immersive Space is OPEN.")
        }

        .onDisappear {
            app.immersiveSpaceState = .closed
            cor.closeAllRooms()
            logger.log("Immersive Space is CLOSED.")
        }
    }

}

// MARK: - **OLD** A SIMD HELPER
/*
/// Extracts the position information.
/// - Returns: The position.
extension simd_float4x4 {
    func to_SIMD3() -> SIMD3<Float> {
        SIMD3(columns.3.x, columns.3.y, columns.3.z)
    }
}
 */

// MARK: - **OLD** ImmersiveView's variables
/*
@EnvironmentObject var warRoom: wRoom

@State private var cameraRight: SIMD3<Float> = SIMD3(1, 0, 0)

@State private var lastPoint: SIMD3<Float>? = nil
*/

// MARK: - **OLD** ARKITSESSION + room transforms
/*
Task {
    try await session.run([worldTracker])
    if let deviceAnchor = worldTracker.queryDeviceAnchor(
        atTimestamp: CACurrentMediaTime()
    ) {
        // The position of the headset (Vision Pro) in cartesian coordinates.
        //                    let devicePos = deviceAnchor.originFromAnchorTransform.to_SIMD3()
        let transform_o = deviceAnchor.originFromAnchorTransform
        warRoom.roomOriginTransform = transform_o
        warRoom.roomOrigin = SIMD3<Float>(
            transform_o.columns.3.x,
            transform_o.columns.3.y,
            transform_o.columns.3.z
        )

        //let roomOriginPoint = Point3D(warRoom.roomOrigin)
        //warRoom.roomOrigin  = TargetE convert(roomOriginPoint , from: .local, to: .scene)
        warRoom.roomDirection = -SIMD3<Float>(
            transform_o.columns.2.x,
            transform_o.columns.2.y,
            transform_o.columns.2.z
        )
        //scene!.raycast(origin: origin, direction: direction)
    }
}
*/

// MARK: - **OLD** SUBSCRIPTION TO GET CAMERA RIGHT DIRECTION VECTOR
/*
//Get the camera right direction vector
_ = content.subscribe(to: SceneEvents.Update.self) { _ in
    Task {
        guard
            let deviceAnchor = worldTracker.queryDeviceAnchor(
                atTimestamp: CACurrentMediaTime()
            )
        else { return }

        let cameraTransform = deviceAnchor.originFromAnchorTransform
        cameraRight = SIMD3<Float>(
            cameraTransform.columns.0.x,
            cameraTransform.columns.0.y,
            cameraTransform.columns.0.z
        )

        //Get the device position
        let deviceAnchorPosition = deviceAnchor
            .originFromAnchorTransform.to_SIMD3()
        //Get the origin point of WarRoom
        var origin = warRoom.roomOrigin
        //Calculate the distance between WarRoom origin and device position
        var distance = distance(deviceAnchorPosition, origin)
        //If the distance is longer than the radius of the room, means the user is outside the room
        //The 0.25 is the little offset that we tested to make it perfectly match the distance of inside and outside
        if distance > Float(warRoom.roomGeometry.roomSize) + 0.25 {
            //If user is outside the room, then the dragging vector becomes negative.
            cameraRight = -cameraRight
        } else {
            //If inside the room, just keet it the same
            cameraRight = cameraRight
        }
    }
}
*/

// MARK: - **OLD** EVERYTHING IN .update
/*
 if warRoom.updateTextures {
 warRoom.updatePanelEntitiesTextureFromLogic()
 warRoom.updateTextures = false
 }

 //This update is where we update the texture of the cubes. I believe that by doing it we will get any edits done to the PDF outside to refresh in the panels (provided we rescan the pdf into images)
 */

// MARK: **OLD** EVERYTHING IN .gesture()
/*
DragGesture(minimumDistance: 15)
    .targetedToAnyEntity()
    .onChanged { value in
        //                    guard let start = value.startInputDevicePose3D?.position,
        //                    let current = value.inputDevicePose3D?.position
        //                    else { return }
        //
        var start: SIMD3<Float> = value.convert(
            value.location3D,
            from: .local,
            to: .scene
        )
        var current: SIMD3<Float> = value.convert(
            value.predictedEndLocation3D,
            from: .local,
            to: .scene
        )
        var directionDetermine = value.translation.width
        //                    var current : SIMD3<Float> = value.convert(value.location3D, from: .local, to: .scene)
        //                    var velocity : SIMD3<Float> = value.convert (value.velocity, from :.local , to: .scene)
        prrint("velocity:\(Double(value.velocity.width).magnitude)")
        warRoom.roomGeometry.dragFactor[0] =
            0.2 * (Double(value.velocity.width).magnitude / 1000)
        warRoom.roomGeometry.dragFactor[1] =
            0.2 / 70
            * (Double(value.velocity.height).magnitude / 1000)
        //                    if Double(value.velocity.width).magnitude > 700 {

        //                    let now = Date()
        //                    if lastPoint == nil || now.timeIntervalSince(lastResetTime) >= resetInterval {
        //                        prrint("lastpoint position: \(lastPoint)")
        //                        lastPoint = current
        //                        lastResetTime = now
        //                    }
        //
        //                    if let start = lastPoint {
        //                        warRoom.dragRoom(p_0: start, p_1: current, camera_right: cameraRight, direction_determine: directionDetermine)
        //                    }
        //                    let prev = lastPoint ?? start
        warRoom.dragRoom(
            p_0: start,
            p_1: current,
            camera_right: cameraRight
        )
        prrint("cameraRight: \(cameraRight)")
        prrint("startx: \(start.x)")
        prrint("starty: \(start.y)")
        prrint("startz: \(start.z)")
        prrint("predictx:\(current.x)")
        prrint("predicty:\(current.y)")
        prrint("predictz:\(current.z)")
        lastPoint = current

        for panel in warRoom._viewPanels {
            if var comp = panel.components[MovingComponent.self] {
                //                            comp.targetAngle = comp.currentAngle + dragDelta
                comp.targetAngle =
                    warRoom.roomGeometry.parameterDraggingOffset[0]
                //                            comp.offset += offset
                comp.offset =
                    warRoom.roomGeometry.parameterDraggingOffset[1]
                comp.transform = panel.transform
                panel.components.set(comp)
            }
        }
        //                    }
    }
    .onEnded { value in

    }
*/

