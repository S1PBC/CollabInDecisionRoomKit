//
//  AttachmentsManager.swift
//
//  Created by Ella Isgar on 12/19/25.
//

import AVKit
import RealityKit
import SwiftUI

class AttachmentsManager: Identifiable {

    var entity: Entity

    private var attachments: [UUID: RoomAttachment]

    init(_ attachments: [RoomAttachment]) {
        let entity = Entity()
        entity.name = "Attachments Entity"
        self.entity = entity

        self.attachments = Dictionary(
            uniqueKeysWithValues: attachments.map { ($0.id, $0) }
        )
    }

    /// AttachmentsManager[some Attachment's UUID] = the Attachment
    subscript(id: UUID) -> RoomAttachment? {
        return attachments[id]
    }

    public func getAllAttachments() -> [RoomAttachment] {

        let attachments = attachments.map { $0.value }

        return attachments
    }

    public func add(_ attachment: RoomAttachment) {
        self.attachments[attachment.id] = attachment
    }
}
