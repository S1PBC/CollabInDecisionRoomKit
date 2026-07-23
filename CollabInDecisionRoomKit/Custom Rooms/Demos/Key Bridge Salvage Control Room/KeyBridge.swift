//
//  KeyBridge.swift
//  Rooms
//
//  Created by Ella Isgar on 1/15/26.
//

import Foundation
import PDFKit
import SwiftUI

/// Creates the "Key Bridge Salvage Control Room".
func makeKeyBridgeSalvageControlRoom() -> Room {

    // Configuring the information that will display for the room's button in the ContentView.
    let prettyName = "Key Bridge Salvage Control Room"

    let roomButtonIcon = RoomButtonIcon.circularRoom

    // Every page of a PDF is going to be placed on a panel in the room.
    let pdfURLString = "KeyBridgeSalvageDemo"

    let pdfURL = Bundle.main.url(
        forResource: pdfURLString,
        withExtension: "pdf"
    )
    let pdfDocument = PDFDocument(url: pdfURL!)!

    let numberOfPanels = pdfDocument.pageCount

    // There will also be a "door" – panel sized gap – in the room.
    let hasDoor = true

    var numberOfSides: Int {
        hasDoor ? (numberOfPanels + 1) : numberOfPanels
    }  // Luis, this is lambda calculus

    // Every panel will have the same height (2m).
    let panelHeight: Float = 2.0

    // A RegularPolygonIncircleRoomGeometry expects every panel to have the same width. Every page of KeyBridge's PDF has the same dimensions. So every panel will have the same width such that the original aspect ratio of the PDF page is preserved (given that the panel height is 2m).
    let pdfDimensions = pdfDocument.getUIImageDimensionsForPage(0)

    let panelWidth: Float =
        panelHeight * Float(pdfDimensions.width / pdfDimensions.height)

    // Every panel will have the same depth (1cm).
    let panelDepth: Float = 0.01

    // Every panel will be placed 10cm apart from each other
    let horizontalPanelPadding: Float = 0.1

    let sideLength = panelWidth + horizontalPanelPadding

    // The room will always open around the user('s origin) and 0.4m off the ground.

    // The room's geometry will be that of a Regular Polygon's Incircle.
    let roomGeometry = RegularPolygonIncircleRoomGeometry(
        numberOfSides: numberOfSides,
        sideLength: sideLength
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
