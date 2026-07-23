//
//  SUPERVDOTTrafficControlRoom.swift
//
//  Created by Ella Isgar on 12/19/25.
//

import Foundation
import PDFKit
import SwiftUI

// AKA:
// 🤩💰💸🤑✨ ATTACHMENTS 🤩💰💸🤑✨ ATTACHMENTS 🤩💰💸🤑✨ ATTACHMENTS 🤩💰💸🤑✨

/// Creates the "VDOT Traffic Control Room" that is shown to the Virgina Department of Transportation
//func makeSUPERVDOTTrafficControlRoom() -> Room {
//
//    // Configuring the information that will display for the room's button in the ContentView.
//    let prettyName = "SUPER VDOT Room"
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
//    // 🤯 ATTACHMENTS GALORE ON PANEL 4 💃
//    let cameraStreamURLs: [String] = [
//        "https://media-sfs7.vdotcameras.com:443/rtplive/NO0018/playlist.m3u8",
//        "https://media-sfs7.vdotcameras.com:443/rtplive/NO0020/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/opct66yoe6sn6vp0cppmp3v5hy4wwuw3/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/qbti5r42pi9q1s91b4rbftylm167g252/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/COFHAMP033/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/COFHAMP034/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/COFHAMP035/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/COFHAMP037/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0009/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0050/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0285/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0438/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0439/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0440/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0445/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0446/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0448/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0449/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0450/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0451/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0452/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0453/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0454/playlist.m3u8",
//        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0162/playlist.m3u8"
//    ]
//
//    let d: Float = -(panelDepth + 0.001)
//    let x: Float = 0.513
//    let yDiff: Float = 0.330 // every rows's y is another -0.330
//    
//    var i = 0
//    for row in 0..<6 {
//        for col in -1..<2 {
//            panels[4].addAttachment(
//                CORAttachment(
//                    // id: "\(row)x\(col)-url\(i)",
//                    content: .hlsStream(
//                        url: cameraStreamURLs[i % cameraStreamURLs.count],
//                        avLayerVideoGravity: .resizeAspectFill
//                    ),
//                    frameWidth: 695,
//                    frameHeight: 445,
//                    position: [x * Float(col), 0.835 - (Float(row) * yDiff), d],
////                    orientation: simd_quaternion(
////                        .pi,
////                        [0, 1, 0]
////                    )
//                )
//            )
//            i+=1
//        }
//    }
//    
//    // 2. Attachment for a live traffic camera feed from https://511.vdot.virginia.gov
//
//    // The current camera feed being displayed is a Camera with a description of (I-66 / MM 52.9 / EB)
//    panels[3].addAttachment(
//        CORAttachment(
//            // id: "VDOT Camera Feed - I-66 / MM 52.9 / EB",
//            content: .hlsStream(
//                url:
//                    "https://media-sfs4.vdotcameras.com:443/rtplive/NROCCTVI66E00529/playlist.m3u8",
//                avLayerVideoGravity: .resizeAspectFill
//            ),
//            frameWidth: 1800,
//            frameHeight: 1110,
//            position: [0, 0.4575, -(panelDepth + 0.001)],
//            orientation: simd_quaternion(
//                .pi,
//                [0, 1, 0]
//            )
//        )
//    )
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
