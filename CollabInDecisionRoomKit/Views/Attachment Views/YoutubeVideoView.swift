import SwiftUI
import WebKit

// MARK: - URL Parsing

enum YTContent {
    case video(id: String)
    case playlist(id: String)

    init?(from urlString: String) {
        // Playlist checked first — watch?v=X&list=Y should be treated as a playlist
        if let pid = urlString.firstCapture(#"[?&]list=([A-Za-z0-9_-]+)"#) {
            self = .playlist(id: pid)
            return
        }
        // Single video: youtu.be/<id>, ?v=<id>, /shorts/<id>, /embed/<id>
        if let vid = urlString.firstCapture(
            #"(?:youtu\.be/|[?&]v=|/shorts/|/embed/)([A-Za-z0-9_-]{11})"#
        ) {
            self = .video(id: vid)
            return
        }
        return nil
    }

}

extension String {
    fileprivate func firstCapture(_ pattern: String) -> String? {
        guard let re = try? NSRegularExpression(pattern: pattern),
            let m = re.firstMatch(
                in: self,
                range: NSRange(startIndex..., in: self)
            ),
            let r = Range(m.range(at: 1), in: self)
        else { return nil }
        return String(self[r])
    }
}

// MARK: - HTML Builder

private func youtubeHTML(content: YTContent) -> String {
    let videoID: String
    let extraVars: String

    switch content {
    case .video(let id):
        videoID = id
        extraVars = ""
    case .playlist(let pid):
        videoID = ""
        extraVars = "listType: 'playlist', list: '\(pid)',"
    }

    return """
        <!doctype html><html><head>
          <meta name="viewport" content="initial-scale=1, maximum-scale=1, user-scalable=no">
          <meta name="referrer" content="strict-origin-when-cross-origin">
          <style>
            html, body { margin: 0; height: 100%; background: #000; }
            #player { position: absolute; inset: 0; width: 100%; height: 100%; }
          </style>
          <script src="https://www.youtube.com/iframe_api"></script>
          <script>
            var player;

            function onYouTubeIframeAPIReady() {
              player = new YT.Player('player', {
                videoId: '\(videoID)',
                playerVars: {
                  controls: 1,
                  rel: 0,
                  playsinline: 1,
                  modestbranding: 1,
                  iv_load_policy: 3,
                  \(extraVars)
                },
                events: {
                  onReady: function() {
                    webkit.messageHandlers.ytReady.postMessage('ready');
                  },
                  onError: function(e) {
                    webkit.messageHandlers.ytError.postMessage(String(e.data));
                  }
                }
              });
            }

            function play()  { player && player.playVideo(); }
            function pause() { player && player.pauseVideo(); }
          </script>
        </head>
        <body><div id="player"></div></body></html>
        """

}

// MARK: - WebView

struct YouTubePlayerView: UIViewRepresentable {

    let urlString: String
    /// nil = unmanaged, true = play, false = pause
    var shouldPlay: Bool? = nil

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsPictureInPictureMediaPlayback = false

        let controller = config.userContentController
        controller.add(context.coordinator, name: "ytReady")
        controller.add(context.coordinator, name: "ytError")

        let web = WKWebView(frame: .zero, configuration: config)
        web.scrollView.isScrollEnabled = false
        web.isOpaque = false
        web.backgroundColor = .black
        context.coordinator.web = web

        load(into: web, coordinator: context.coordinator)
        return web
    }

    func updateUIView(_ web: WKWebView, context: Context) {
        let coordinator = context.coordinator

        if coordinator.loadedURL != urlString {
            coordinator.playerReady = false
            coordinator.loadedURL = nil
            load(into: web, coordinator: coordinator)
        }

        coordinator.desiredPlay = shouldPlay
        coordinator.syncPlayState()
    }

    private func load(into web: WKWebView, coordinator: Coordinator) {
        guard let content = YTContent(from: urlString) else { return }
        let bundleID = Bundle.main.bundleIdentifier ?? "com.local.app"
        let baseURL = URL(string: "https://\(bundleID.lowercased())")!
        web.loadHTMLString(youtubeHTML(content: content), baseURL: baseURL)
        coordinator.loadedURL = urlString
    }

    final class Coordinator: NSObject, WKScriptMessageHandler {
        weak var web: WKWebView?
        var loadedURL: String?
        var playerReady = false
        var desiredPlay: Bool? = nil

        func userContentController(
            _ controller: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            switch message.name {
            case "ytReady":
                playerReady = true
                syncPlayState()
            case "ytError":
                logger.error("[YouTubePlayerView] player error: \(message.body)")
            default:
                break
            }
        }

        func syncPlayState() {
            guard playerReady, let web, let desired = desiredPlay else { return }
            web.evaluateJavaScript(desired ? "play()" : "pause()")
        }
    }
}

struct ReactiveYouTubePlayerView: View {
    let urlString: String
    let bindings: [RoomBinding]
    let attachmentID: UUID

    @State private var autoPlayEnabled: Bool
    @State private var headTrackedPlay: Bool = false

    init(urlString: String, bindings: [RoomBinding], attachmentID: UUID) {
        self.urlString = urlString
        self.bindings = bindings
        self.attachmentID = attachmentID

        if let binding = bindings.first(where: {
            $0.intendedAction.isSameCase(as: .toggle_headTrackedAutoplay(false))
        }),
           case .toggle(let value) = binding.initialState {
            self._autoPlayEnabled = State(initialValue: value)
        } else {
            self._autoPlayEnabled = State(initialValue: false)
        }
    }

    var body: some View {
        YouTubePlayerView(
            urlString: urlString,
            shouldPlay: autoPlayEnabled ? headTrackedPlay : nil
        )
        // User toggling autoplay on/off via a RoomControl
        .onReceive(NotificationCenter.default.publisher(for: .controlStateUpdated)) { notification in
            guard
                let update = notification.object as? RoomControlStateUpdate,
                let binding = bindings.first(where: {
                    $0.control == update.source &&
                    $0.intendedAction.isSameCase(as: .toggle_headTrackedAutoplay(false))
                }),
                case .toggle(let value) = update.state
            else { return }

            autoPlayEnabled = value
        }
        // Head tracking loop reporting which attachment is active
//        .onReceive(NotificationCenter.default.publisher(for: .headTrackingUpdated)) { notification in
//            guard let update = notification.object as? HeadTrackingUpdate,
//                  bindings.contains(where: { $0.control == update.source })
//            else { return }
//            
//            headTrackedPlay = (update.activeID == attachmentID)
//        }
        .onReceive(NotificationCenter.default.publisher(for: .headTrackingUpdated)) { notification in
            guard let update = notification.object as? HeadTrackingUpdate,
                  bindings.contains(where: { $0.control == update.source })
            else {
                logger.log("[YT \(attachmentID)] headTrackingUpdated ignored — source not in bindings")
                return
            }

            let shouldPlay = (update.activeID == attachmentID)
            logger.log("[YT \(attachmentID)] activeID=\(String(describing: update.activeID)) shouldPlay=\(shouldPlay)")
            headTrackedPlay = shouldPlay
        }
    }
}

@Observable
class VideoPlaybackState {
    var isPlaying: Bool = false
}
