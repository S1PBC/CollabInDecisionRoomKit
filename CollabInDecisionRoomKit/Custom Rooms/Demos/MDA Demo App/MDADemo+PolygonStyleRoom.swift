//
//  MDADemo+PolygonStyleRoom.swift
//
//  Created by Ella Isgar on 12/17/25.
//

import Foundation
import PDFKit

/// Creates the "Polygon Style Room" that is shown to the Missile Defense Agency (MDA)
func makeMDADemo_PolygonStyleRoom() -> Room {

//    index: Int, 🆕
//    label: String, 🆕
//    pdfName: String, 🆕
//    roomButtonIcon: RoomButtonIcon = .circularRoom, ➡️ .sealOfMDA_UNCLASS
//    hasDoor: Bool = true, ✔️
//    panelHeight _panelHeight: Float = 3.0, ❌
//    panelWidth _panelWidth: Float? = nil, ➡️ 3
//    panelDepth: Float = 0.02, ✔️
//    padding: Float = 0.1, ✔️ // Every panel will be placed 10cm apart from each other
//    origin: SIMD3<Float> = [0, 0, 0],
//    minNumOfPanels: Int = 8,
//    maxNumOfPanels: Int = 8,
    let room = PolygonStyleRoom(
        index: 1,
        label: "Polygon Style Room",
        pdfName: "MDADemoApp_CombinedPages",
        roomButtonIcon: .sealOfMDA_UNCLASS,
        panelWidth: 3, // Every panel will have the same width (3m).
        origin: [0, 0.4, 0] // The room will always open around the user('s origin) and 0.4m off the ground.
    )!

    return room

}
