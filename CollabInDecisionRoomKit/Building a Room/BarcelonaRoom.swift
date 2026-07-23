//
//  BarcelonaRoom.swift
//  Rooms
//
//  Created by Ella Isgar on 2/18/26.
//

import Foundation
import PDFKit

class BarcelonaStyleRoom: Room {

    /// Old specs:
    ///     - Creates a room with the following specifications:
    ///     - every panel is one page from the provided PDF
    ///     - the WIDTH of every panel is 3 meters
    ///     - the HEIGHT of every panel preserves the aspect ratio of the first page of the provided PDF
    ///         - NOTE: this assumes every page of the provided PDF is the same size.
    ///     - the THICKNESS of every panel is 0.01 meters (1cm)
    ///     - each panel will have 0.5 meters of horizontal padding (0.1 meters of padding btwn each panel)
    ///     - no attachments
    ///     - cornerRadius: of each corner's circular arc.

    /**
     The default __Barcelona__ style room.
    
     - Parameters:
        - index: Where the room will be listed in the ``AvailableRoomsView``. The rooms are listed by index in ascending order (i.e., index of 0 ==> room is first on the list).
        - label: The label of the room's button.
        - pdfName: The __base__ name of the PDF that will determine the base content of each panel. Do not include the file's extension (e.g., ".pdf").
            > NOTE:
                - The number of pages in the PDF determines the number of panels in the room.
                - The _first_ page of the PDF determines the aspect ratio of _every_ panel.
        - hasDoor: If `true`, a door (i.e., a gap the size of the other panels), will be added into the room. When the room renders in, the door will be placed directly behind the user.
            > ℹ️ Default value is `true`.
        - panelWidth: The width (m) of every panel. This value is not used if a height is provided in `panelHeight`.
            > ℹ️ Default value is `3.0`.
        - panelHeight: The height (m) of every panel.
            > ℹ️ Default value is `nil`. When no value is provided, the panel height is determined by the `panelWidth` and aspect ratio of the first page of the PDF.
        - panelDepth: The depth (m) of every panel.
            > ℹ️ Default value is `0.02`.
        - padding: The padding (m) around the left and right edges of each panel.
            > ℹ️ Default value is `0.1`.
        - cornerRounding: Defines how the corners and edges of all panel are rendered. See ``CornerRounding`` for all options.
            > ℹ️ Default value is `.uniform()`. This results in a uniform corner radius, capped to 1/2 the panelDepth. This case also results in each PDF page appearing "squished" along all edges of the panel.
        - origin: The [x, y, z] position of the room when first opened.
            > ℹ️ Default value is `[0, 0, 0]`. When the room is opened, the user will be placed directly in the center of the room, panels appearing to rest on the floor.
     */
    // TODO: Validate input.
    // TODO: Add input debug string.
    // TODO: Add outcome debug string (room successfully made? or nil)
    // TODO: Confirm well-commented and readable.
    init?(
        index: Int,
        label: String,
        pdfName: String,
        roomButtonIcon: RoomButtonIcon = .circularRoom,
        hasDoor: Bool = true,
        panelWidth: Float = 3.0,
        panelHeight: Float? = nil,
        panelDepth: Float = 0.02,
        panelCornerRounding: PanelCornerRounding = .uniform(),
        padding: Float = 0.1,
        origin: SIMD3<Float> = [0, 0, 0],
        inRadiusMult: Float = 1, //0.8,  // 1.0 = circular <1.0 = proper barcelona,
    ) {

        let pdfURL = Bundle.main.url(
            forResource: pdfName,
            withExtension: "pdf"
        )!
        let pdfDocument = PDFDocument(url: pdfURL)!

        let numberOfPanels = pdfDocument.pageCount

        var numberOfSides: Int {
            hasDoor ? (numberOfPanels + 1) : numberOfPanels
        }

        let centralAngleArcLength = panelWidth + padding

        let roomGeometry = RegularPolygonIncircleRoomGeometry(
            numberOfSides: numberOfSides,
            centralAngleArcLength: centralAngleArcLength,
            roomOriginOffset: origin
        )

        let pdfDimensions = pdfDocument.getUIImageDimensionsForPage(0)

        let panelHeight: Float =
            panelWidth * Float(pdfDimensions.height / pdfDimensions.width)

        var panels: [Panel] = []

        for i in 0..<numberOfPanels {

            var index: Int {
                hasDoor ? (i + 1) : i
            }

            let panelShape = CurvedRectangularPrism(
                width: panelWidth,
                height: panelHeight,
                depth: panelDepth,
                radiusOfCurvature: Float(roomGeometry.inradius) * inRadiusMult,
                cornerRounding: panelCornerRounding
            )

            let materialManager = MaterialManager(
                pdfURLString: pdfName,
                pdfPageNumber: i
            )

            let panel = Panel(
                index: index,
                shape: panelShape,
                materialManager: materialManager,
            )

            panels.append(panel)

        }

        super.init(
            roomGeometry: roomGeometry,
            panels: panels,
            prettyName: label,
            roomButtonIcon: roomButtonIcon,
            index: index
        )
    }

}
