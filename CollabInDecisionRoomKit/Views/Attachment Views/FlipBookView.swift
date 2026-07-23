//
//  FlipBookView.swift
//  Rooms
//
//  Created by Ella Isgar on 2/10/26.

import SwiftUI

struct ReactiveFlipBookView: View {
    let path: String
    let bindings: [RoomBinding]

    /// When on, the "flipping" animation is playing. When off, the "flipping" animation is frozen on the frame
    /// that was showing when the toggle was flipped to false.
    ///
    /// NOTE: A default flipbook view must NOT be animating when room first loaded containing the view/attachment.
    @State private var isFlipping: Bool

    init(path: String, bindings: [RoomBinding], isFlipping: Bool = false) {
        self.path = path
        self.bindings = bindings
        self.isFlipping = isFlipping
    }

    var body: some View {
        FlipBookView(path: path, isFlipping: isFlipping)
            .onReceive(
                NotificationCenter.default.publisher(for: .controlStateUpdated)
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
                case .toggle_flip:
                    isFlipping = value
                default:
                    break
                }
            }

    }
}

// ⚠️ CPU-driven (not GPU-optimal). Fine for <60 frames.
struct FlipBookView: UIViewRepresentable {

    let path: String
    let isFlipping: Bool
    let frameInterval: TimeInterval = 0.2

    func makeUIView(context: Context) -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.setContentHuggingPriority(.defaultLow, for: .horizontal)
        iv.setContentHuggingPriority(.defaultLow, for: .vertical)
        iv.setContentCompressionResistancePriority(
            .defaultLow,
            for: .horizontal
        )
        iv.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        context.coordinator.loadImages(from: path)
        context.coordinator.setup(imageView: iv, interval: frameInterval)

        if isFlipping { context.coordinator.start() }
        return iv
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        if isFlipping {
            context.coordinator.start()
        } else {
            context.coordinator.stop()
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(path: path) }

    final class Coordinator {
        private var path: String
        private var images: [UIImage] = []
        private var timer: Timer?
        private var index = 0
        private weak var imageView: UIImageView?
        private var interval: TimeInterval = 0.2

        init(path: String) {
            self.path = path
        }

        func loadImages(from folder: String) {
            var i = 0
            let exts = ["jpg", "jpeg", "png"]
            outer: while true {
                for ext in exts {
                    let inRoot = Bundle.main.path(
                        forResource: "\(path)_frame\(i)",
                        ofType: ext
                    )
                    let inDir =
                        folder.isEmpty
                        ? nil
                        : Bundle.main.path(
                            forResource: "\(path)_frame\(i)",
                            ofType: ext,
                            inDirectory: folder
                        )
                    if let path = inRoot ?? inDir,
                        let img = UIImage(contentsOfFile: path)
                    {
                        images.append(img)
                        i += 1
                        continue outer
                    }
                }
                break
            }
            if images.isEmpty {
                logger.error(
                    "FlipBookView: No images found for path '\(folder)'"
                )
            } else {
                logger.log(
                    "FlipBookView: Loaded \(images.count) images from bundle root."
                )
            }
        }

        func setup(imageView: UIImageView, interval: TimeInterval) {
            self.imageView = imageView
            self.interval = interval
            imageView.image = images.first
        }

        func start() {
            guard !images.isEmpty else { return }
            guard timer == nil else { return }  // already running
            timer = Timer.scheduledTimer(
                withTimeInterval: interval,
                repeats: true
            ) { [weak self] _ in
                guard let self, let iv = self.imageView else { return }
                self.index = (self.index + 1) % self.images.count
                iv.image = self.images[self.index]
            }
        }

        func stop() {
            timer?.invalidate()
            timer = nil
            // Hold on current frame
        }

        deinit { stop() }
    }
}
