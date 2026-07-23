////
////  VideoPlaybackSystem.swift
////
////  Created by Ella Isgar on 5/15/26.
////
//
//import RealityKit
//import Observation
//
//@Observable
//class VideoPlaybackState {
//    var isPlaying: Bool = false
//    var autoPlayEnabled: Bool = true
//}
//
//struct VideoPlaybackComponent: Component {
//    var autoPlayEnabled: Bool = true
//    var isPlaying: Bool = false
//}
//
//class VideoPlaybackSystem: System {
//    required init(scene: RealityKit.Scene) {}
//
//    func update(context: SceneUpdateContext) {
//        // Single raycast from head, once per frame
//        guard let hit = context.scene.raycast(
//            origin: headPosition,
//            direction: gazeDirection,
//            query: .nearest,
//            mask: .all
//        ).first else {
//            // Nothing hit — pause everything
//            for entity in context.entities(matching: .init(where: .has(VideoPlaybackComponent.self)), updatingSystemWhen: .rendering) {
//                entity.components[VideoPlaybackComponent.self]?.isPlaying = false
//            }
//            return
//        }
//
//        for entity in context.entities(matching: .init(where: .has(VideoPlaybackComponent.self)), updatingSystemWhen: .rendering) {
//            let shouldPlay = (entity == hit.entity)
//            entity.components[VideoPlaybackComponent.self]?.isPlaying = shouldPlay
//        }
//    }
//}
