//
//  ReactiveHLSStreamView.swift
//
//  Created by Ella Isgar on 02/25/26.
//

import AVKit
import SwiftUI

struct ReactiveHLSStreamView: View {
    let urlString: String
    let avLayerVideoGravity: AVLayerVideoGravity
    let bindings: [RoomBinding]

    @State private var loadFailed: Bool = false

    /// A default HLS Stream view must NOT be streaming when room first loaded containing the view/attachment.
    @State private var isPlaying: Bool

    init(
        urlString: String,
        avLayerVideoGravity: AVLayerVideoGravity,
        bindings: [RoomBinding],
        isPlaying: Bool = false
    ) {
        self.urlString = urlString
        self.avLayerVideoGravity = avLayerVideoGravity
        self.bindings = bindings
        self.isPlaying = isPlaying
    }

    var body: some View {
        #if targetEnvironment(simulator)
            simulatorPlaceholder
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: .controlStateUpdated
                    )
                ) { notification in
                    guard
                        let update = notification.object as? RoomControlStateUpdate,
                        let binding = bindings.first(where: {
                            $0.control == update.source
                        }),
                        case .toggle(let value) = update.state
                    else { return }

                    // binding.intendedAction tells us what case to produce
                    switch binding.intendedAction {
                    case .toggle_stream:
                        isPlaying = value
                    default:
                        break
                    }
                }
        #else
            if loadFailed {
                failurePlaceholder
            } else {
                HLSStreamView(
                    urlString: urlString,
                    avLayerVideoGravity: avLayerVideoGravity,
                    isPlaying: isPlaying,
                    onLoadFailed: { loadFailed = true }
                )
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: .controlStateUpdated
                    )
                ) { notification in
                    guard
                        let update = notification.object as? RoomControlStateUpdate,
                        let binding = bindings.first(where: {
                            $0.control == update.source
                        }),
                        case .toggle(let value) = update.state
                    else { return }

                    // binding.intendedAction tells us what case to produce
                    switch binding.intendedAction {
                    case .toggle_stream:
                        isPlaying = value
                    default:
                        break
                    }
                }
            }
        #endif
    }

    private var simulatorPlaceholder: some View {
        ZStack {
            Color.black
            VStack(spacing: 8) {
                Image(
                    systemName: isPlaying ? "play.rectangle" : "pause.rectangle"
                )
                .font(.system(size: 48))
                .animation(.easeInOut(duration: 0.2), value: isPlaying)
                Text(isPlaying ? "Playing" : "Paused")
                    .font(.extraLargeTitle)
                Text(urlString)
                    .font(.caption)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .foregroundStyle(.secondary)
            .padding()
        }
    }

    private var failurePlaceholder: some View {
        ZStack {
            Color.black
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                Text("Stream unavailable")
                    .font(.largeTitle)
            }
            .foregroundStyle(.secondary)
        }
    }
}

struct HLSStreamView: UIViewRepresentable {
    let urlString: String
    let avLayerVideoGravity: AVLayerVideoGravity
    let isPlaying: Bool
    var onLoadFailed: (() -> Void)? = nil

    func makeUIView(context: Context) -> PlayerUIView {
        let view = PlayerUIView()
        view.backgroundColor = .black

        let playerLayer = AVPlayerLayer()
        playerLayer.videoGravity = avLayerVideoGravity
        view.playerLayer = playerLayer
        view.layer.addSublayer(playerLayer)
        context.coordinator.playerLayer = playerLayer

        return view
    }

    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        context.coordinator.onLoadFailed = onLoadFailed

        if context.coordinator.player == nil {
            guard let url = URL(string: urlString) else { return }

            let headers = [
                "User-Agent":
                    "Mozilla/5.0 (AppleVisionPro; CPU visionOS 1_0 like Mac OS X)"
            ]
            let asset = AVURLAsset(
                url: url,
                options: ["AVURLAssetHTTPHeaderFieldsKey": headers]
            )
            let playerItem = AVPlayerItem(asset: asset)

            context.coordinator.statusObservation = playerItem.observe(
                \.status,
                options: [.new]
            ) { item, _ in
                guard item.status == .failed else { return }
                context.coordinator.statusObservation = nil
                logger.error(
                    "Player failed: \(item.error?.localizedDescription ?? "unknown")"
                )
                DispatchQueue.main.async { context.coordinator.onLoadFailed?() }
            }

            let player = AVPlayer(playerItem: playerItem)
            player.automaticallyWaitsToMinimizeStalling = true
            context.coordinator.player = player
            context.coordinator.playerLayer?.player = player

            if isPlaying { player.play() }
            return
        }

        if isPlaying {
            context.coordinator.player?.play()
        } else {
            context.coordinator.player?.pause()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onLoadFailed: onLoadFailed)
    }

    final class Coordinator {
        var onLoadFailed: (() -> Void)?
        var player: AVPlayer?
        var playerLayer: AVPlayerLayer?
        var statusObservation: NSKeyValueObservation?
        var shouldPlay: Bool = true

        init(onLoadFailed: (() -> Void)? = nil) {
            self.onLoadFailed = onLoadFailed
        }

        deinit {
            statusObservation?.invalidate()
            player?.pause()
        }
    }
}

final class PlayerUIView: UIView {
    var playerLayer: AVPlayerLayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        // Called by UIKit whenever bounds change — guarantees
        // playerLayer always has the correct frame before rendering
        playerLayer?.frame = bounds
    }
}
