//
//  PolygonRoom.swift
//
//  Created by Ella Isgar on 2/18/26.
//

import Foundation
import PDFKit

class PolygonStyleRoom: Room {

    /**
     The default __Polygon__ style room.
    
     - Parameters:
        - index: Where the room will be listed in the ``AvailableRoomsView``. The rooms are listed by index in ascending order (i.e., index of 0 ==> room is first on the list).
        - label: The label of the room's button.
        - pdfName: The __base__ name of the PDF that will determine the base content of each panel. Do not include the file's extension (e.g., ".pdf").
            > NOTE:
                - The number of pages in the PDF determines the number of panels in the room.
                - The _first_ page of the PDF determines the aspect ratio of _every_ panel.
        - hasDoor: If `true`, a door (i.e., a gap the size of the other panels), will be added into the room. When the room renders in, the door will be placed directly behind the user.
            > ℹ️ Default value is `true`.
        - panelHeight: The height (m) of every panel. This value is not used if a width is provided in `panelWidth`.
            > ℹ️ Default value is `3.0`.
        - panelWidth: The width (m) of every panel.
            > ℹ️ Default value is `nil`. When no value is provided, the panel width is determined by the `panelHeight` and aspect ratio of the first page of the PDF.
        - panelDepth: The depth (m) of every panel.
            > ℹ️ Default value is `0.02`.
        - padding: The padding (m) around the left and right edges of each panel.
            > ℹ️ Default value is `0.1`.
        - origin: The [x, y, z] position of the room when first opened.
            > ℹ️ Default value is `[0, 0, 0]`. When the room is opened, the user will be placed directly in the center of the room, panels appearing to rest on the floor.
        - minNumOfPanels: The minumum number of panels the room will show.
            > NOTE:
                - If the number of PDF pages is less than the minNumOfPanels, enough doors will be added to ensure the room's final number of sides is >= minNumOfPanels.
            > ℹ️ Default value is `8`.
        - maxNumOfPanels: The maximum number of panels the room will show.
             > NOTE:
                 - If the number of PDF pages is greater than the maxNumOfPanels, only the first `maxNumOfPanels` pages will be displayed on panels.
             > ℹ️ Default value is `8`.
     */
    // TODO: Confirm well-commented and readable.
    // TODO: Allow the panel rendered in front of the user upon opening the room to be configurable.
    // TODO: Confirm w Luis - what is the expected behavior for the doorXpanel layout? Spaced out? Clumped on one side? What panel should be placed in front of the user.
    init?(
        index: Int,
        label: String,
        pdfName: String,
        roomButtonIcon: RoomButtonIcon = .circularRoom,
        hasDoor: Bool = true,
        panelHeight _panelHeight: Float = 3.0,
        panelWidth _panelWidth: Float? = nil,
        panelDepth: Float = 0.02,
        panelCornerRounding: PanelCornerRounding = .uniform(),
        padding: Float = 0.1,
        origin: SIMD3<Float> = [0, 0, 0],
        minNumOfPanels: Int = 8,
        maxNumOfPanels: Int = 8,
    ) {

        let debugString: String =
            """
            Provided Parameters:
            index: \(index)
            label: \(label)
            pdfName: \(pdfName)
            hasDoor: \(hasDoor)
            panelHeight: \(String(describing: _panelHeight))
            panelWidth: \(String(describing: _panelWidth))
            panelDepth: \(panelDepth)
            panelCornerRounding: \(panelCornerRounding)
            padding: \(padding)
            origin: \(origin)
            minNumOfPanels: \(minNumOfPanels)
            maxNumOfPanels: \(maxNumOfPanels)
            """

        // MARK: INPUT VALIDATION
        if label.isEmpty {
            logger.warning(
                "No label provided. The room's button will have label."
            )
        }

        if pdfName.isEmpty {
            logger.error(
                """
                No pdfName provided. Can not create a room.

                \(debugString)
                """
            )
            return nil
        }

        if pdfName.contains(".pdf") {
            logger.warning(
                "The extension \".pdf\" was identified in the pdfName. This is undefined behavior."
            )
        }

        if minNumOfPanels <= 0 || minNumOfPanels > maxNumOfPanels {
            logger.error(
                "Invalid minimum/maxiumum number of panels."
            )
            return nil
        }

        let pdfURL = Bundle.main.url(
            forResource: pdfName,
            withExtension: "pdf"
        )!
        let pdfDocument = PDFDocument(url: pdfURL)!

        let numOfPages = pdfDocument.pageCount

        // NOTE: There is a minimum and maximum # of panels in a polygon-style room.
        let numberOfPanels = min(numOfPages, maxNumOfPanels)

        // Any panel that does not have a PDF page is a door (panel-sized gap).
        let numberOfEmptySides =
            (numberOfPanels < minNumOfPanels)
            ? minNumOfPanels - numberOfPanels : 0

        let numberOfSides =
            numberOfPanels + numberOfEmptySides + (hasDoor ? 1 : 0)

        let pdfDimensions = pdfDocument.getUIImageDimensionsForPage(0)

        let panelHeight: Float
        let panelWidth: Float

        if _panelWidth != nil {
            panelWidth = _panelWidth!
            panelHeight =
                panelWidth * Float(pdfDimensions.height / pdfDimensions.width)
        } else {
            panelHeight = _panelHeight
            panelWidth =
                panelHeight * Float(pdfDimensions.width / pdfDimensions.height)
        }

        let sideLength = panelWidth + padding

        let roomGeometry = RegularPolygonIncircleRoomGeometry(
            numberOfSides: numberOfSides,
            sideLength: sideLength,
            roomOriginOffset: origin
        )

        var panels: [Panel] = []

        for i in 0..<numberOfPanels {

            var index: Int {
                hasDoor ? (i + 1) : i
            }

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
                index: index,
                shape: panelShape,
                materialManager: materialManager
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

    // NO PDF
    /**
     The default __Polygon__ style room.
    
     - Parameters:
        - index: Where the room will be listed in the ``AvailableRoomsView``. The rooms are listed by index in ascending order (i.e., index of 0 ==> room is first on the list).
        - label: The label of the room's button.
        - pdfName: The __base__ name of the PDF that will determine the base content of each panel. Do not include the file's extension (e.g., ".pdf").
            > NOTE:
                - The number of pages in the PDF determines the number of panels in the room.
                - The _first_ page of the PDF determines the aspect ratio of _every_ panel.
        - hasDoor: If `true`, a door (i.e., a gap the size of the other panels), will be added into the room. When the room renders in, the door will be placed directly behind the user.
            > ℹ️ Default value is `true`.
        - panelHeight: The height (m) of every panel. This value is not used if a width is provided in `panelWidth`.
            > ℹ️ Default value is `3.0`.
        - panelWidth: The width (m) of every panel.
            > ℹ️ Default value is `nil`. When no value is provided, the panel width is determined by the `panelHeight` and aspect ratio of the first page of the PDF.
        - panelDepth: The depth (m) of every panel.
            > ℹ️ Default value is `0.02`.
        - padding: The padding (m) around the left and right edges of each panel.
            > ℹ️ Default value is `0.1`.
        - origin: The [x, y, z] position of the room when first opened.
            > ℹ️ Default value is `[0, 0, 0]`. When the room is opened, the user will be placed directly in the center of the room, panels appearing to rest on the floor.
        - minNumOfPanels: The minumum number of panels the room will show.
            > NOTE:
                - If the number of PDF pages is less than the minNumOfPanels, enough doors will be added to ensure the room's final number of sides is >= minNumOfPanels.
            > ℹ️ Default value is `8`.
        - maxNumOfPanels: The maximum number of panels the room will show.
             > NOTE:
                 - If the number of PDF pages is greater than the maxNumOfPanels, only the first `maxNumOfPanels` pages will be displayed on panels.
             > ℹ️ Default value is `8`.
     */
    // TODO: Confirm well-commented and readable.
    // TODO: Allow the panel rendered in front of the user upon opening the room to be configurable.
    // TODO: Confirm w Luis - what is the expected behavior for the doorXpanel layout? Spaced out? Clumped on one side? What panel should be placed in front of the user.
    init?(
        index: Int,
        label: String,
        roomButtonIcon: RoomButtonIcon = .circularRoom,
        numberOfPanels: Int,
        hasDoor: Bool = true,
        panelColor: UIColor = .white,
        panelColorRoughness: Float = 0.0,
        panelColorIsMetallic: Bool = false,
        panelOpacity: Float = 1.0,
        panelHeight: Float = 3.0,
        panelWidth: Float = 2.0,
        panelDepth: Float = 0.02,
        panelCornerRounding: PanelCornerRounding = .uniform(),
        padding: Float = 0.1,
        origin: SIMD3<Float> = [0, 0, 0],
        minNumOfPanels: Int = 3,
        maxNumOfPanels: Int = 8,
    ) {

        let debugString: String =
            """
            Provided Parameters:
            index: \(index)
            label: \(label)
            numberOfPanels: \(numberOfPanels)
            hasDoor: \(hasDoor)
            panelColor: \(panelColor)
            panelColorRoughness: \(panelColorRoughness)
            panelColorIsMetallic: \(panelColorIsMetallic)
            panelHeight: \(panelHeight)
            panelWidth: \(panelWidth)
            panelDepth: \(panelDepth)
            panelCornerRounding: \(panelCornerRounding)
            padding: \(padding)
            origin: \(origin)
            minNumOfPanels: \(minNumOfPanels)
            maxNumOfPanels: \(maxNumOfPanels)
            """

        // MARK: INPUT VALIDATION
        if label.isEmpty {
            logger.warning(
                "No label provided. The room's button will have label."
            )
        }

        if minNumOfPanels <= 0 || minNumOfPanels > maxNumOfPanels {
            logger.error(
                "Invalid minimum/maxiumum number of panels."
            )
            return nil
        }

        // NOTE: There is a minimum and maximum # of panels in a polygon-style room.
        let numberOfPanels = min(numberOfPanels, maxNumOfPanels)

        let numberOfSides = numberOfPanels + (hasDoor ? 1 : 0)

        let sideLength = panelWidth + padding

        let roomGeometry = RegularPolygonIncircleRoomGeometry(
            numberOfSides: numberOfSides,
            sideLength: sideLength,
            roomOriginOffset: origin
        )

        var panels: [Panel] = []

        for i in 0..<numberOfPanels {

            var index: Int {
                hasDoor ? (i + 1) : i
            }

            let panelShape = RectangularPrism(
                width: panelWidth,
                height: panelHeight,
                depth: panelDepth,
                cornerRounding: .uniform()
            )

            let materialManager = MaterialManager(
                simpleColor: panelColor,
                roughness: panelColorRoughness,
                isMetallic: panelColorIsMetallic,
            )

            let panel = Panel(
                index: index,
                shape: panelShape,
                opacity: panelOpacity,
                materialManager: materialManager
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
