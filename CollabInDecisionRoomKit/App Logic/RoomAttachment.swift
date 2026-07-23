//
//  RoomAttachment.swift
//  DecisionRoomKit
//
//  Created by Ella Isgar on 5/7/26.
//

import AVKit
import SwiftUI

/// Represents a Swift UI view that is placed on/around a specific panel.
class RoomAttachment: Identifiable {

    var id = UUID()

    let type: AttachmentType

    let frameWidth: CGFloat?
    let frameHeight: CGFloat?

    let scale: SIMD3<Float>

    var position: SIMD3<Float>
    let orientation: simd_quatf

    var bindings: [RoomBinding] = []

    enum AttachmentType {
        case website(url: String)
        case hlsStream(
            url: String,
            avLayerVideoGravity: AVLayerVideoGravity = .resizeAspectFill
        )
        case flipbook(path: String)
        case youtube(url: String)
    }

    init(
        type: AttachmentType,
        frameWidth: CGFloat? = nil,
        frameHeight: CGFloat? = nil,
        scale: Float,
        position: SIMD3<Float>,
        orientation: simd_quatf = simd_quaternion(
            .pi,
            [0, 1, 0]
        )
    ) {
        self.type = type
        self.frameWidth = frameWidth
        self.frameHeight = frameHeight
        self.scale = SIMD3<Float>(repeating: scale)
        self.position = position
        self.orientation = orientation
    }

    @ViewBuilder
    var view: some View {

        switch type {
        case .website(let url):
            ReactiveWebsiteView(
                url: url,
                bindings: bindings
            )

        case .hlsStream(let url, let gravity):
            ReactiveHLSStreamView(
                urlString: url,
                avLayerVideoGravity: gravity,
                bindings: bindings
            )

        case .flipbook(let path):
            ReactiveFlipBookView(
                path: path,
                bindings: bindings
            )

        case .youtube(let url):
            ReactiveYouTubePlayerView(
                urlString: url,
                bindings: bindings,
                attachmentID: self.id
            )
        }
    }
}
