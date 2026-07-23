//
//  USNavy2024NavPlan.swift
//  Rooms
//
//  Created by Ella Isgar on 2/3/26.
//

import Foundation
import PDFKit
import SwiftUI

/// Creates the "US Navy 2024 Navigation Plan" room.
func makeUSNavy2024NavPlanRoom() -> Room {

    // Configuring the information that will display for the room's button in the ContentView.
    let prettyName = "US NAVY 2024 NAV Plan"

    let roomButtonIcon = RoomButtonIcon.helixRoom

    // Every page of a PDF is going to be placed on a panel in the room.
    let pdfURLString = "CNO-NavigationPlan-2024"

    let pdfURL = Bundle.main.url(
        forResource: pdfURLString,
        withExtension: "pdf"
    )
    let pdfDocument = PDFDocument(url: pdfURL!)!

    let numberOfPanels = pdfDocument.pageCount

    // No "door" – panel sized gap – in a helix room.
    let hasDoor = true
    
    let totalNumberOfPanels = hasDoor ? numberOfPanels + 1 : numberOfPanels

    // Every panel will have the same width (1.55m).
    let panelWidth: Float = 1.55

    // So every panel will have the same height such that the original
    // aspect ratio of the PDF page is preserved (given that the panel
    // width is 1.55m).
    let pdfDimensions = pdfDocument.getUIImageDimensionsForPage(0)

    let panelHeight: Float =
        panelWidth * Float(pdfDimensions.height / pdfDimensions.width)

    // Every panel will have the same depth (1cm).
    let panelDepth: Float = 0.01

    // Every panel will be placed 10cm apart from each other horizontally
    let horizontalPanelPadding: Float = 0.1
    
    // Every panel will be have 5cm of padding along its top and bottom
    let verticalPanelPadding: Float = 0.1

    // The room will always open around the user('s origin) and on the ground.
    let roomOriginOffset = SIMD3<Float>(0, 0, 0)
    
    let initialFocusIndex: Float = 5.0

    // The room's geometry will be that of a Right Circular Cylinder's Helix.
    let roomGeometry = CircularHelixRoomGeometry(
        totalNumberOfPanels: totalNumberOfPanels,
        panelWidth: panelWidth,
        horizontalPanelPadding: horizontalPanelPadding,
        panelHeight: panelHeight,
        verticalPanelPadding: verticalPanelPadding,
        roomOriginOffset: roomOriginOffset,
        initialFocusIndex: initialFocusIndex
    )

    // Now to define the panels in this room!
    var panels: [Panel] = []

    for i in 0..<numberOfPanels {

        var index: Int {
            hasDoor ? (i + 1) : i
        }

        // Every panel will have a Rectangular Prism shape.
        let panelShape = RectangularPrism(
            width: panelWidth,
            height: panelHeight,
            depth: panelDepth,
            cornerRounding: .uniform()
        )

        // One PDF page will be displayed on each panel.
        let materialManager = MaterialManager(
            pdfURLString: pdfURLString,
            pdfPageNumber: i
        )

        let panel = Panel(
            index: index,
            shape: panelShape,
            materialManager: materialManager,
            // attachments: attachments // NOTE: Adding attachments here is optional.
        )

        panels.append(panel)

    }

    let room = Room(
        roomGeometry: roomGeometry,
        panels: panels,
        prettyName: prettyName,
        roomButtonIcon: roomButtonIcon
    )

    return room

}

////
////  USNavy2024NavPlan.swift
////  Rooms
////
////  Created by Ella Isgar on 2/3/26.
////
//
//import Foundation
//import PDFKit
//import SwiftUI
//
///// Creates the "US Navy 2024 Navigation Plan" room.
//func makeUSNavy2024NavPlanRoom() -> Room {
//
//    let id = "USNavy2024NavPlan"
//
//    // Configuring the information that will display for the room's button in the ContentView.
//    let prettyName = "US NAVY 2024 NAV Plan"
//
//    let roomButtonIcon = RoomButtonIcon.helixRoom
//
//    // Every page of a PDF is going to be placed on a panel in the room.
//    let pdfURLString = "CNO-NavigationPlan-2024"
//
//    let pdfURL = Bundle.main.url(
//        forResource: pdfURLString,
//        withExtension: "pdf"
//    )
//    let pdfDocument = PDFDocument(url: pdfURL!)!
//
//    let numberOfPanels = pdfDocument.pageCount
//
//    // No "door" – panel sized gap – in a helix room.
//    let hasDoor = true
//
//    // Every panel will have the same width (1.55m).
//    let panelWidth: Float = 1.55
//
//    // So every panel will have the same height such that the original
//    // aspect ratio of the PDF page is preserved (given that the panel
//    // width is 1.55m).
//    let pdfDimensions = pdfDocument.getUIImageDimensionsForPage(0)
//
//    let panelHeight: Float =
//        panelWidth * Float(pdfDimensions.height / pdfDimensions.width)
//
//    // Every panel will have the same depth (1cm).
//    let panelDepth: Float = 0.01
//
//    // Every panel will be placed 10cm apart from each other horizontally
//    let horizontalPanelPadding: Float = 0.1
//
//    let sideLength = panelWidth + horizontalPanelPadding
//
//    // Every panel will be have 5cm of padding along its top and bottom
//    let verticalPanelPadding: Float = 0.1
//
//    let floorHeight = panelHeight + verticalPanelPadding
//
//    // The room will always open around the user('s origin) and on the ground.
//    let roomOriginOffset = SIMD3<Float>(0, 0, 0)
//
//    // The room's geometry will be that of a Right Circular Cylinder's Helix.
//    let roomGeometry = CircularHelixRoomGeometry(
//        totalNumberOfPanels: <#T##Int#>,
//        panelWidth: <#T##Float#>,
//        horizontalPanelPadding: <#T##Float#>,
//        panelHeight: <#T##Float#>,
//        verticalPanelPadding: <#T##Float#>,
//        roomOriginOffset: <#T##SIMD3<Float>#>
//    )
//    //    let roomGeometry = CircularCylindricalHelixRoomGeometry(
//    //        hasDoor: hasDoor,
//    //        numberOfPanels: numberOfPanels,
//    //        sideLength: sideLength,
//    //        floorHeight: floorHeight,
//    //        roomOriginOffset: roomOriginOffset
//    //    )
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
//            roomID: id,
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
//    let room = Room(
//        id: id,
//        roomGeometry: roomGeometry,
//        panels: panels,
//        prettyName: prettyName,
//        roomButtonIcon: roomButtonIcon
//    )
//
//    return room
//
//}
