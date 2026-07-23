//
//  MDADemo+VideoCarouselRoom.swift
//  DecisionRoomKit
//
//  Created by Ella Isgar on 5/12/26.
//

import SwiftUI

func makeMDADemo_VideoCarouselRoom() -> Room {

    let room = PolygonStyleRoom(
        index: 3,
        label: "Video Carousel Room",
        numberOfPanels: 8,
        // panelColor: .init(red: 0, green: 0, blue: 39 / 255, alpha: 1),
        panelOpacity: 0.5,
        panelHeight: 4.5,
        panelWidth: 8,
        panelDepth: 0.01,
    )!

    // Create a control to toggle the opacity of the panel.
    let transparencyToggle = RoomControl(
        label: "Transparent Panel",
        altLabel: "Opaque Panel",
        initialUIState: .toggle(false)
    )

    for panel in room.panels {
        room.bind(
            control: transparencyToggle,
            panel: panel,
            intendedAction: .toggle_panel_transparency(false)
        )
    }

    let urls: [String] = [
        "https://youtu.be/-QiG4vKdCoM?si=ydM2pg7tr54a3-ET",
        "https://youtu.be/YIQWmBIedno?si=q4rZrt_l7gF6mPCq",
        "https://youtu.be/4r5IONxPUvs?si=2RSVaYU0_t7sgruY",
        "https://youtu.be/-q-ieXZgrhY?si=g5HqE7ppaWqrys6F",
        "https://youtu.be/4T0PXGh5rLI?si=mFRX0cC1OXwLaXQK",
        "https://youtube.com/playlist?list=PLb-SvVbiey_fTKGJVgQTIFU5SvfU7zrM6&si=NfZ2qKmbP6cz_BoK",
        "https://youtu.be/kxRDK2SYSlg?si=r1rNEidEDjre1NRe",
        "https://youtu.be/UU5o2KfblIQ?si=pfK_pyZs6p7GuW5o",
    ]

    let ytAttachmentFrameWidth: CGFloat = 1280
    let ytAttachmentFrameHeight: CGFloat = ytAttachmentFrameWidth * 9 / 16
    
    // Create a control to toggle the head-tracking autoplay feature of each youtube attachment.
    let headTrackingAutoPlayToggle = RoomControl(
        label: "Head-tracking Auto Play OFF",
        altLabel: "Head-tracking Auto Play ON",
        initialUIState: .toggle(true)
    )

    for (i, url) in urls.enumerated() {
        let ytAttachment = room.addAttachmentTo(
            panelIndex: i + 1,
            type: .youtube(url: url),
            frameWidth: ytAttachmentFrameWidth,
            frameHeight: ytAttachmentFrameHeight,
            scale: 7.5
        )!
        
        room.bind(
            control: headTrackingAutoPlayToggle,
            attachment: ytAttachment,
            intendedAction: .toggle_headTrackedAutoplay(true)
        )
    }

    return room
}
