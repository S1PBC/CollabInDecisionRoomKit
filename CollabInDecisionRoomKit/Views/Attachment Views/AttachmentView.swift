//
//  AttachmentView.swift
//  Rooms
//
//  Created by Ella Isgar on 2/25/26.
//

import SwiftUI

struct AttachmentView: View {
    let attachment: RoomAttachment

    @State private var isVisible: Bool

    init(_ attachment: RoomAttachment) {
        self.attachment = attachment
        
        // The attachment's default visibility is set to true if no control in the room is binded to the attachment's visibility (+ consequently, there is no initial visibility state as set by the control)
        if let binding = attachment.bindings.first(where: {
            $0.intendedAction.isSameCase(as: .toggle_visibility(false))
        }),
           case .toggle(let value) = binding.initialState
        {
            self._isVisible = State(initialValue: value)
        } else {
            self._isVisible = State(initialValue: true)
        }
        
        logger.notice(
            "INITIAL VISIBILITY of AttachmentView for \(attachment.id) = \(isVisible)"
        )
    }

    var body: some View {
        Group {
            if isVisible { attachment.view }
        }
        .frame(width: attachment.frameWidth, height: attachment.frameHeight)
        .onReceive(
            NotificationCenter.default.publisher(for: .controlStateUpdated)
        ) { notification in
            guard let update = notification.object as? RoomControlStateUpdate,
                attachment.bindings.contains(where: {
                    $0.control == update.source &&
                    $0.intendedAction.isSameCase(as: .toggle_visibility(false))
                }),
                  case .toggle(let value) = update.state
            else { return }

            isVisible = value
        }
    }
}
