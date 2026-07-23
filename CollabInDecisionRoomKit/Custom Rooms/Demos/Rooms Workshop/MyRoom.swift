import Foundation
import RealityKit

func makeMyPolgyonRoom() -> Room {

    let room: Room = PolygonStyleRoom(
        index: 0,
        label: "My Polygon Room",
        pdfName: "rainbow",
    )!

    // MARK: .flipbook

    // Create the attachment
    let flipbookAttachment = room.addAttachmentTo(
        panelIndex: 5,
        type: .flipbook(path: "RunningFrames"),
    )!

    // Create a control to toggle the flipping of the flipbook attachment.
    let flippingToggle = RoomControl(
        label: "Not Flipping",
        altLabel: "Flipping",
        initialUIState: .toggle(false)
    )

    room.bind(
        control: flippingToggle,
        attachment: flipbookAttachment,
        intendedAction: .toggle_flip(false)
    )

    // MARK: .hlsStream

    // Create the attachment

    let hlsStreamAttachment = room.addAttachmentTo(
        panelIndex: 4,
        type: .hlsStream(
            url:
                "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8",
            avLayerVideoGravity: .resizeAspectFill
        )
    )!

    // Create a control to toggle the streaming of the hls attachment.
    let streamingToggle = RoomControl(
        label: "Not Streaming",
        altLabel: "Streaming",
        initialUIState: .toggle(false)
    )

    room.bind(
        control: streamingToggle,
        attachment: hlsStreamAttachment,
        intendedAction: .toggle_stream(false)
    )

    return room
}

// TODO: SOMETHING IS WRONG WITH THE DEFAULT BUILD. ROOM IS SHIFTED UP. FIX.
func makeMyBarcelonaRoom() -> Room {

    let room: Room = BarcelonaStyleRoom(
        index: 2,
        label: "My Barcelona Room",
        pdfName: "rainbow",
    )!

    return room
}

func makeMyHelixRoom() -> Room {

    let room: Room = HelixStyleRoom(
        index: 3,
        label: "My Helix Room",
        pdfName: "rainbow",
    )!

    for panel in room.panels {

        // Create attachment
        let websiteAttachment = room.addAttachmentTo(
            panelIndex: panel.index,
            type: .website(url: "https://randomcolour.com")
        )!

        // Create a control to toggle the flipping of the flipbook attachment.
        let refreshButton = RoomControl(
            label: "🔄 Refresh Page",
            initialUIState: .button
        )

        room.bind(
            control: refreshButton,
            attachment: websiteAttachment,
            intendedAction: .refresh
        )

    }

    return room
}

func makeVDOTRoom() -> Room {

    let room: Room = PolygonStyleRoom(
        index: 4,
        label: "VDOT Control Room",
        pdfName: "VDOTTrafficControlRoom",
    )!

    // Create the attachments
    
    // Website
    let websiteAttachment = room.addAttachmentTo(
        panelIndex: 2,
        type: .website(url: "https://www.spc.noaa.gov/exper/href/"),
        frameWidth: 2200,  // 1950,
        frameHeight: 1800,  // 1650, //1550,
        x: -0.3,
        y: 2.2
    )!

    // HLS Stream
    let hlsAttachment = room.addAttachmentTo(
        panelIndex: 5,
        type: .hlsStream(
            url:
                "https://media-sfs5.vdotcameras.com/rtplive/FairfaxVideo4160/playlist.m3u8"
        ),
        frameWidth: 1000,
        frameHeight: 800,
        x: -0.4,
        y: 1.85
    )!
    
    // Flipbook
    let flipbookAttachment = room.addAttachmentTo(
        panelIndex: 4,
        type: .flipbook(path: "VDOTFrames"),
        frameWidth: 2700, // 2100,
        frameHeight: 1790, // 1185,
        x: 0,
        y: 0.675
    )!

    // MARK: Press to turn on/off simulated live data
    let simulatedLiveDataToggle = RoomControl(
        label: "Press to turn on simulated live data",
        altLabel: "Press to turn off simulated live data",
        initialUIState: .toggle(false)
    )
    
    room.bind(
        control: simulatedLiveDataToggle,
        attachment: flipbookAttachment,
        intendedAction: .toggle_flip(false)
    )
    
//    let playAction = room.addAction(initialState: .boolean(false))  // flipbook loads NOT playing.
//    room.addControl(
//        label: "Press to turn on simulated live data",
//        altLabel: "Press to turn off simulated live data",
//        kind: .toggle,
//        actionIDs: [playAction.id]
//    )
//    room.bind(
//        actionID: playAction.id,
//        to: flipbook?.id ?? UUID(),
//        response: .flip
//    )

    // MARK: Press to turn on/off real-time live data
    // Create a control to toggle the flipping of the flipbook attachment.
    let realTimeLiveDataToggle = RoomControl(
        label: "Press to turn on real-time live data",
        altLabel: "Press to turn off real-time live data",
        initialUIState: .toggle(false)
    )
    
    room.bind(
        control: realTimeLiveDataToggle,
        attachment: websiteAttachment,
        intendedAction: .toggle_visibility(false)
    )
    
    room.bind(
        control: realTimeLiveDataToggle,
        attachment: hlsAttachment,
        intendedAction: .toggle_visibility(false)
    )
    
//    let visibilityAction = room.addAction(initialState: .boolean(true))  // TODO: Change back to false
//    room.addControl(
//        label: "Press to turn off real-time live data",
//        altLabel: "Press to turn on real-time live data",
//        kind: .toggle,
//        actionIDs: [visibilityAction.id]
//    )

//    room.bind(
//        actionID: visibilityAction.id,
//        to: website?.id ?? UUID(),
//        response: .visibility
//    )
//    room.bind(
//        actionID: visibilityAction.id,
//        to: hlsStream?.id ?? UUID(),
//        response: .visibility
//    )

    /*
    let cameraStreamURLs: [String] = [
        "https://media-sfs7.vdotcameras.com:443/rtplive/NO0018/playlist.m3u8",
        "https://media-sfs7.vdotcameras.com:443/rtplive/NO0020/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/opct66yoe6sn6vp0cppmp3v5hy4wwuw3/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/qbti5r42pi9q1s91b4rbftylm167g252/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/COFHAMP033/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/COFHAMP034/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/COFHAMP035/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/COFHAMP037/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0009/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0050/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0285/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0438/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0439/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0440/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0445/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0446/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0448/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0449/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0450/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0451/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0452/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0453/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0454/playlist.m3u8",
        "https://media-sfs1.vdotcameras.com:443/rtplive/NO0162/playlist.m3u8",
    ]

    let x: Float = 0.513
    let yDiff: Float = 0.330  // every rows's y is another -0.330

    var i = 0
    for row in 0..<6 {
        for col in -1..<2 {
            room.addAttachmentWithControl(
                to: 4,
                content: .hlsStream(
                    url: cameraStreamURLs[i]
                ),
                frameWidth: 695,
                frameHeight: 445,
                position: [x * Float(col), 0.835 - (Float(row) * yDiff)],
                controlLabel: "⏯️ [\(row + 1)x\(col + 2)] Stream",
                controlValue: .toggle(true),

            )
            i += 1
        }
    }*/

    return room

}
