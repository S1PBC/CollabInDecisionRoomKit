//
//  RoomButton.swift
//
//  Created by Ella Isgar on 12/1/25.
//

import AVFAudio
import SwiftUI

// TODO: Move all sound-related functionality to the SoundManager. Goal is to call on the SoundManager to play the desired sound effect e.g. soundManager.play("some audio file")

/// A button for a ``Room``. The visual information of the button is stored in the room associated with the button.
///
/// When the button is pressed:
/// 1. A sound effect is played.
/// 2. The immersive space is opened if not already open.
/// 3. The selected room is opened via COR (incl. queuing a new ``CORCommand``).
struct RoomButton: View {

    @Environment(AppLogic.self) var app
    @Environment(COR.self) var cor
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    let roomID: UUID
    let roomButtonIcon: RoomButtonIcon
    let prettyName: String

    //    var audioPlayer: AVAudioPlayer?
    static var soundEffectFileName = "RoomButtonPressedSoundEffect"

    @State private var audioPlayer: AVAudioPlayer? = {
        guard
            let url = Bundle.main.url(
                forResource: RoomButton.soundEffectFileName,
                withExtension: ".mp3"
            )
        else { return nil }
        return try? AVAudioPlayer(contentsOf: url)
    }()

    var body: some View {
        HStack {
            roomButtonIcon.view
            Button(
                action: { handleTap() },
                label: {
                    Text(prettyName)
                        .lineLimit(1)
                        .font(.title2)
                        .padding(.vertical)
                        .frame(width: 250)
                }
            )
            .disabled(
                app.immersiveSpaceState == .inTransition || cor.anyRoomIsLoading
            )
            .padding(.vertical)
        }
    }

    func handleTap() {
        logger.log("RoomButton(\(roomID)) has been triggered.")
        playSoundEffect()

        Task { @MainActor in
            switch app.immersiveSpaceState {

            case .open:
                // Space already open — switch rooms directly.
                cor.submit(
                    CORCommand(action: .open(roomID), source: .local)
                )

            case .closed:
                // Guard against re-entry while opening.
                app.immersiveSpaceState = .inTransition

                switch await openImmersiveSpace(id: app.immersiveSpaceID) {
                case .opened:
                    // ImmersiveView.onAppear will set state to .open.
                    // Open the room once the space is ready.
                    cor.submit(
                        CORCommand(action: .open(roomID), source: .local)
                    )
                case .userCancelled:
                    app.immersiveSpaceState = .closed
                    logger.log("User cancelled opening immersive space.")
                case .error:
                    app.immersiveSpaceState = .closed
                    logger.error("Failed to open immersive space.")
                @unknown default:
                    app.immersiveSpaceState = .closed
                }

            case .inTransition:
                // Ignore taps while the space is transitioning.
                break
            }
        }
    }

    func playSoundEffect() {
        audioPlayer?.volume = 0.1
        audioPlayer?.play()
    }
}

extension ControllerOfRooms {
    
    /// A convenience function for COR
    public func createRoomButton(for id: UUID) -> RoomButton {
        let room = getRoom(id)
        return RoomButton(
            roomID: room.id,
            roomButtonIcon: room.roomButtonIcon,
            prettyName: room.prettyName
        )
    }
    
}
