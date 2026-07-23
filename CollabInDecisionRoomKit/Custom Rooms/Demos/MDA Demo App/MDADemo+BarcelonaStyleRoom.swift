//
//  MDADemo+BarcelonaStyleRoom.swift
//
//  Created by Ella Isgar on 12/17/25.
//

import Foundation
import PDFKit

/// Creates the "Barcelona Style Room" that is shown to the Missile Defense Agency (MDA)
func makeMDADemo_BarcelonaStyleRoom() -> Room {

//    index: Int, 🆕
//    label: String, 🆕
//    pdfName: String, 🆕
//    roomButtonIcon: RoomButtonIcon = .circularRoom, ➡️ .sealOfMDA_UNCLASS
//    hasDoor: Bool = true, ✔️
//    panelWidth: Float = 3.0, ✔️
//    panelHeight: Float? = nil, ✔️
//    panelDepth: Float = 0.02, ✔️
//    panelCornerRounding: PanelCornerRounding = .uniform(), ✔️
//    padding: Float = 0.1, ✔️
//    origin: SIMD3<Float> = [0, 0, 0], ➡️ [0, 0.4, 0]
//    inRadiusMult: Float = 1, //0.8,  // 1.0 = circular <1.0 = proper barcelona,
    let room = BarcelonaStyleRoom(
        index: 2,
        label: "Barcelona Style Room",
        pdfName: "MDADemoApp_CombinedPages",
        roomButtonIcon: .sealOfMDA_UNCLASS,
        origin: [0, 0.4, 0],
    )!

    return room

}
