//
//  HelixRoom.swift
//  Rooms
//
//  Created by Ella Isgar on 2/18/26.
//

import Foundation
import PDFKit

class HelixStyleRoom: Room {

    /// Specifications:
    ///     - roomGeometry = ``CircularHelixRoomGeometry``
    ///     - every panel is one page from the provided PDF
    ///     - panelShape = ``RectangularPrism``
    ///     - the WIDTH of every panel is 1.55 meters
    ///     - the HEIGHT of every panel preserves the aspect ratio of the first page of the provided PDF
    ///         - NOTE: this assumes every page of the provided PDF is the same size.
    ///     - the THICKNESS of every panel is 0.01 meters (1cm)
    ///     - each panel will have 0.2 meters of horizontal + vertical padding (0.1 meters of padding btwn each panel)
    ///     - no attachments
    ///     - room is placed at user's origin

    /**
     The default __Helix__ style room.
    
     - Parameters:
        - index: Where the room will be listed in the ``AvailableRoomsView``. The rooms are listed by index in ascending order (i.e., index of 0 ==> room is first on the list).
        - label: The label of the room's button.
        - pdfName: The __base__ name of the PDF that will determine the base content of each panel. Do not include the file's extension (e.g., ".pdf").
            > NOTE:
                - The number of pages in the PDF determines the number of panels in the room.
                - The _first_ page of the PDF determines the aspect ratio of _every_ panel.
            > ℹ️ Default value is `true`.
        - panelWidth: The width (m) of every panel. This value is not used if a height is provided in `panelHeight`.
            > ℹ️ Default value is `1.55`.
        - panelHeight: The height (m) of every panel.
            > ℹ️ Default value is `nil`. When no value is provided, the panel height is determined by the `panelWidth` and aspect ratio of the first page of the PDF.
        - panelDepth: The depth (m) of every panel.
            > ℹ️ Default value is `0.02`.
        - horizontalPadding: The padding (m) around the left and right edges of each panel.
            > ℹ️ Default value is `0.1`.
        - verticalPadding: The padding (m) around the top and bottom edges of each panel.
            > ℹ️ Default value is `0.1`.
        - cornerRounding: Defines how the corners and edges of all panel are rendered. See ``CornerRounding`` for all options.
            > ℹ️ Default value is `.uniform()`. This results in a uniform corner radius, capped to 1/2 the panelDepth. This case also results in each PDF page appearing "squished" along all edges of the panel.
        - panelsPerRevolution: The number of panels that will be placed along one revolution of the helix geometry.
            > ℹ️ Default value is `10`.
        - origin: The [x, y, z] position of the room when first opened.
            > ℹ️ Default value is `[0, 0, 0]`. When the room is opened, the user will be placed directly in the center of the room, panels appearing to rest on the floor.
        - indexOfInitialPanel: The index of the panel that is placed in front of the user when the room opens.
            > ℹ️ Default value is `0`.
     */
    // TODO: What is the expected behavior between padding of the panels, panelsPerRevolution, and the # of panels? How should these values be prioritized if one violates the other? Should the option of a radius be provided as a way to define the room geometry here?
    // TODO: Add ability to "insert" a door in place of a pdf panel.
    // TODO: Validate input.
    // TODO: Add input debug string.
    // TODO: Add outcome debug string (room successfully made? or nil)
    // TODO: Confirm well-commented and readable.
    init?(
        index: Int,
        label: String,
        pdfName: String,
        panelWidth: Float = 1.55,
        panelHeight: Float? = nil,
        panelDepth: Float = 0.02,
        horizontalPadding: Float = 0.1,
        verticalPadding: Float = 0.1,
        panelsPerRevolution: Int = 10,
        origin: SIMD3<Float> = [0, 0, 0],
        indexOfInitialPanel: Float = 0,
    ) {

        let pdfURL = Bundle.main.url(
            forResource: pdfName,
            withExtension: "pdf"
        )!
        let pdfDocument = PDFDocument(url: pdfURL)!

        let totalNumberOfPanels = pdfDocument.pageCount

        let pdfDimensions = pdfDocument.getUIImageDimensionsForPage(0)

        let panelHeight: Float =
            panelWidth * Float(pdfDimensions.height / pdfDimensions.width)

        let roomGeometry = CircularHelixRoomGeometry(
            totalNumberOfPanels: totalNumberOfPanels,
            panelsPerRevolution: panelsPerRevolution,
            panelWidth: panelWidth,
            horizontalPanelPadding: horizontalPadding,
            panelHeight: panelHeight,
            verticalPanelPadding: verticalPadding,
            roomOriginOffset: origin,
            initialFocusIndex: indexOfInitialPanel
        )

        var panels: [Panel] = []

        for i in 0..<totalNumberOfPanels {

            let panelShape = RectangularPrism(
                width: panelWidth,
                height: panelHeight,
                depth: panelDepth,
                cornerRounding: .uniform()
            )

            let materialManager = MaterialManager(
                pdfURLString: pdfName,
                pdfPageNumber: i
            )

            let panel = Panel(
                index: i,
                shape: panelShape,
                materialManager: materialManager,
            )

            panels.append(panel)

        }

        super.init(
            roomGeometry: roomGeometry,
            panels: panels,
            prettyName: label,
            roomButtonIcon: RoomButtonIcon.helixRoom,
            index: index
        )

    }

}
