//
//  VDOTControlRoom.swift
//
//  Created by Ella Isgar on 12/19/25.
//

import Foundation
import PDFKit
import SwiftUI

/// Creates the "VDOT Traffic Control Room" that is shown to the Virgina Department of Transportation
//func makeVDOTTrafficControlRoom() -> Room {
//
//    // Configuring the information that will display for the room's button in the ContentView.
//    let prettyName = "VDOT Control Room"
//
//    let roomButtonIcon = RoomButtonIcon.circularRoom
//
//    // Every page of a PDF is going to be placed on a panel in the room.
//    // Old PDF name was "VDOT Traffic Control Room Demo w Simulated RT Video"
//    let pdfURLString = "VDOTRoom"
//
//    let pdfURL = Bundle.main.url(
//        forResource: pdfURLString,
//        withExtension: "pdf"
//    )
//    let pdfDocument = PDFDocument(url: pdfURL!)!
//
//    let numberOfPanels = pdfDocument.pageCount
//
//    // There will also be a "door" – panel sized gap – in the room.
//    let hasDoor = true
//
//    var numberOfSides: Int {
//        hasDoor ? (numberOfPanels + 1) : numberOfPanels
//    }  // Luis, this is lambda calculus
//
//    // Every panel will have the same height (2m).
//    let panelHeight: Float = 2.0
//
//    // A RegularPolygonIncircleRoomGeometry expects every panel to have the same width. Every page of VDOT's PDF has the same dimensions. So every panel will have the same width such that the original aspect ratio of the PDF page is preserved (given that the panel height is 2m).
//    let pdfDimensions = pdfDocument.getUIImageDimensionsForPage(0)
//
//    let panelWidth: Float =
//        panelHeight * Float(pdfDimensions.width / pdfDimensions.height)
//
//    // Every panel will have the same depth (1cm).
//    let panelDepth: Float = 0.01
//
//    // Every panel will be placed 10cm apart from each other
//    let horizontalPanelPadding: Float = 0.1
//
//    let sideLength = panelWidth + horizontalPanelPadding
//
//    // The room will always open around the user('s origin) and 0.4m off the ground.
//
//    // The room's geometry will be that of a Regular Polygon's Incircle.
//    let roomGeometry = RegularPolygonIncircleRoomGeometry(
//        numberOfSides: numberOfSides,
//        sideLength: sideLength
//    )
//
//    // Now to define the panels in this room!
//    var panels: [Panel] = []
//
//    for i in 0..<numberOfPanels {
//
//        var index: Int {
//            hasDoor ? (i + 1) : i
//        }
//
//        // Every panel will have a Rectangular Prism shape.
//        let panelShape = RectangularPrism(
//            width: panelWidth,
//            height: panelHeight,
//            thickness: panelDepth
//        )
//
//        // One PDF page will be displayed on each panel.
//        let materialManager = MaterialManager(
//            pdfURLString: pdfURLString,
//            pdfPageNumber: i
//        )
//
//        let panel = Panel(
//            index: index,
//            shape: panelShape,
//            materialManager: materialManager,
//            // attachments: attachments // NOTE: Adding attachments here is optional.
//        )
//
//        panels.append(panel)
//
//    }
//
//    // There are 3 attachments in this room.
//
//    // 1. Attachment for a live traffic camera feed from https://511.vdot.virginia.gov
//
//    // The current camera feed being displayed is Camera 22 of 33 on VA-7 (VA-7 / MM 59.8 / EB)
//
//    // To get a different video:
//    // 1. Visit https://511.vdot.virginia.gov
//    // 2. Choose a camera. Take note of the "description" in the top blue section (e.g. "VA-7 / MM 59.8 / EB".
//    // 3. Visit https://511.vdot.virginia.gov/services/map/layers/map/cams
//    // 4. ⌘+F for the description. Make sure that there are no extra characters.
//    // 5. Grab the "https_url" associated with the "description". This is the url you enter below.
//    panels[4].addAttachment(
//        CORAttachment(
//            // id: "VDOT Camera Feed - VA-7 / MM 59.8 / EB",
//            content: .hlsStream(
//                url:
//                    "https://media-sfs1.vdotcameras.com:443/rtplive/FairfaxVideo2004/playlist.m3u8",
//                avLayerVideoGravity: .resizeAspectFill
//            ),
//            frameWidth: 695,
//            frameHeight: 445,
//            position: [-0.513, 0.835, -(panelDepth + 0.001)],
//            orientation: simd_quaternion(
//                .pi,
//                [0, 1, 0]
//            )
//        )
//    )
//
//    // 2. Attachment for a flip book view (to demonstrate live data being processed internally).
//
////    // The pictures being flipped through are from the VDOT camera feed of (I-66 / MM 52.9 / EB)
////    panels[3].addAttachment(
////        CORAttachment(
////            id: "VDOT Camera Feed - I-66 / MM 52.9 / EB",
//////            content: .hlsStream(
//////                url:
//////                    "https://media-sfs4.vdotcameras.com:443/rtplive/NROCCTVI66E00529/playlist.m3u8",
//////                avLayerVideoGravity: .resizeAspectFill
//////            ),
////            content: .flipbook(path: "FlipBookFrames"),
////            frameWidth: 1800,
////            frameHeight: 1110,
////            position: [0, 0.4575, -(panelDepth + 0.001)],
////            orientation: simd_quaternion(
////                .pi,
////                [0, 1, 0]
////            )
////        )
////    )
//
//    // 3. Attachment for a Storm Prediction Center website page @ https://www.spc.noaa.gov/exper/href/
//    panels[1].addAttachment(
//        CORAttachment(
//            // id: "Storm Prediction Center Website",
//            content: .website(url: "https://www.spc.noaa.gov/exper/href/"),
//            frameWidth: 1500,
//            position: [-0.25, 1.2, -(panelDepth + 0.001)],
//            orientation: simd_quaternion(
//                .pi,
//                [0, 1, 0]
//            )
//        )
//    )
//
//    let room = Room(
//        roomGeometry: roomGeometry,
//        panels: panels,
//        prettyName: prettyName,
//        roomButtonIcon: roomButtonIcon
//    )
//
//    return room
//
//}
