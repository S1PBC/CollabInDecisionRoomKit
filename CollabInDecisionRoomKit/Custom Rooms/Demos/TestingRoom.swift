//
//  TestingRoom.swift
//  Rooms
//
//  Created by Ella Isgar on 4/2/26.
//

//func makeTestingRoom() -> Room? {
//
//    // MARK: Make room.
//    guard
//        let room = PolygonStyleRoom(
//            index: 0,
//            label: "Testing Room",
//            pdfName: "rainbow"
//        )
//    else {
//        logger.error("Failed to make the Testing Room.")
//        return nil
//    }
//
//    // MARK: - Configuring room's Control System
//
//    // MARK: Flipbook (toggle 1. play/pause and 2. visibility)
//    // 1. Add an attachment to a panel.
//    let flipBookAttachment = room.addAttachment(
//        to: 5,
//        content: .flipbook(path: "RunningFrames")
//    )!
//
//    // 2. Create an action (with an initial state).
//    let flipAction = room.addAction(initialState: .boolean(false))
//
//    // 3. Create a control that is wired to the action.
//    room.addControl(
//        label: "Start Running",
//        altLabel: "Stop Running",
//        kind: .toggle,
//        actionIDs: [flipAction.id]
//    )
//
//    // 4. Bind the action to the attachment with a response.
//    room.bind(
//        actionID: flipAction.id,
//        to: flipBookAttachment.id,
//        response: .flip
//    )
//    
////    // MARK: Visibility
////    // 2. Create action.
////    let visibilityAction = room.addAction(initialState: .boolean(false))
////    
////    // 3. Create a control wired to action.
////    room.addControl(
////        label: "Show FlipBook Attachment",
////        altLabel: "Hide FlipBook Attachment",
////        kind: .toggle,
////        actionIDs: [visibilityAction.id]
////    )
////
////    // 4. Bind action to attachment w a response.
////    room.bind(
////        actionID: visibilityAction.id,
////        to: flipBookAttachment.id,
////        response: .visibility
////    )
//
//    return room
//}
