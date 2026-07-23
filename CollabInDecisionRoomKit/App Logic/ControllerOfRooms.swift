//
//  ControllerOfRooms.swift
//
//  Created by Ella Isgar on 12/11/25.
//

import ARKit
import Combine
import Observation
import PDFKit
import RealityKit
import SwiftUI

typealias COR = ControllerOfRooms

@Observable
/// An object to be responsible for *everything* rooms in this app.
class ControllerOfRooms {

    /// All rooms available for viewing in the app.
    ///
    /// - NOTE: A dictionary => O(1) look up time via a room's id.
    private var rooms: [UUID: Room]

    /// Is any single room currently being loaded?
    ///
    /// Used by some of ContentView's content as a global LOADING indicator.
    // public var anyRoomIsLoading: Bool = false
    var anyRoomIsLoading: Bool = false {
        didSet {
            //            logger.debug(
            //                "🔄 anyRoomIsLoading changed: \(oldValue) -> \(anyRoomIsLoading)"
            //            )
        }
    }

    var onRoomPlacementComplete: (() -> Void)? = nil

    /// A computed property so views can observe the currently open room.
    ///
    /// Since COR is @Observable and mutates room.state on open/close, SwiftUI will
    /// automatically re-evaluate any view that reads cor.openRoom
    public var openRoom: Room? {
        rooms.values.first { $0.state == .open }
    }

    /// This RealityKit entity is the parent for every room entity.
    public var entity: Entity

    // MARK: S1 Industries PBC Logos

    /// Ceiling logo.
    private var logo1: Entity

    /// Transparent logo.
    private var logo2: Entity

    // MARK: - Messages
    private(set) var messages: [CORMessage] = []

    /// Posts a message to the Control Room Messages view.
    func post(_ text: String) {
        messages.append(CORMessage(text))
    }

    // MARK: - COR Command System

    /// Publishes commands from local sources and external systems (e.g. SharePlay).
    /// Commands flow through this pipeline before being queued for execution.
    private let commandPublisher = PassthroughSubject<CORCommand, Never>()

    /// Serial queue responsible for all command ordering and execution.
    /// Ensures thread-safe, deterministic processing of commands.
    private let commandProcessingQueue = DispatchQueue(
        label: "ControllerOfRooms.command.processing.queue",
        qos: .userInitiated
    )

    /// FIFO buffer of pending commands awaiting execution.
    /// Only accessed on `commandProcessingQueue`.
    private var commandQueue: [CORCommand] = []

    /// Holds active Combine subscriptions to keep the processing pipeline alive for the lifetime of the COR.
    private var cancellables = Set<AnyCancellable>()

    // MARK: - ARKitSession + Providers

    /// The app's main entry point for receiving data from ARKit.
    private let session: ARKitSession

    /// A source of live data about the device pose and anchors in the user's surroundings.
    private let worldTracking: WorldTrackingProvider

    init() {

        self.rooms = [:]

        self.anyRoomIsLoading = false

        let entity = Entity()
        entity.name = "Rooms Entity"
        self.entity = entity

        // TODO: Add logo configuration into room creation. (When creating a room, should be able to toggle which logos are wanted in the room and where.
        // TODO: Add an option to place logos in diff positions. E.g. at the distance the panels are from the origin (for when in polygon-incircle geometry) + about a foot above the panel.
        // TODO: Once the todo above is finished, move this line below to the creation of the VDOT Room.
        // The following line is transforming the second logo purely to make look visible / better in the VDOT Room.
        //        logo2.move(
        //            to: Transform(translation: .init(0, 1.1, -1.3)),
        //            relativeTo: nil
        //        )

        let logo1 = createS1IndustriesPBCLogoEntity1()
        let logo2 = createS1IndustriesPBCLogoEntity2()
        entity.addChild(logo1)
        entity.addChild(logo2)
        logo1.isEnabled = false
        logo2.isEnabled = false
        self.logo1 = logo1
        self.logo2 = logo2

        self.session = ARKitSession()

        self.worldTracking = WorldTrackingProvider()

        addRooms()

        setupCORCommandSystemPipeline()

    }

    /// Creates all preconfigured rooms and registers them with the controller.
    ///
    /// - NOTE: This function is where you add any rooms you want to be offered in-app immediately after initialization.
    private func addRooms() {

        for room in roomsToPreload {
            rooms[room.id] = room
        }

    }

    /// Returns a list of all rooms managed by the controller.
    ///
    /// - Returns: An array of ``Room`` objects.
    public func getRooms() -> [Room] {
        return rooms.map({ $0.value })
    }

    /// Returns the room associated with the given ``RoomID``.
    ///
    /// - Parameters:
    ///     - id: The id of the desired room.
    /// - Returns: The matching room, or a generic fallback.
    public func getRoom(_ id: UUID) -> Room {

        guard let realRoom = rooms[id] else {
            return aGenericRoom
        }
        return realRoom

    }

    /// Collects every ``AttachmentsManager`` from every panel in every room.
    ///
    /// - Returns: A flattened array of all attachment managers.
    public func getAllAttachmentsManagers() -> [AttachmentsManager] {
        var managers: [AttachmentsManager] = []

        for room in rooms.values {
            for panel in room.panels {
                managers.append(panel.attachmentsManager)
            }
        }

        return managers
    }

    /// Collects every ``RoomAttachment`` from every panel's attachment manager in every room.
    ///
    /// - Returns: A flattened array of all attachment managers.
    public func getAllAttachments() -> [RoomAttachment] {
        var attachments: [RoomAttachment] = []

        for room in rooms.values {
            for panel in room.panels {
                attachments += panel.attachmentsManager.getAllAttachments()
            }
        }

        return attachments
    }

    public func closeAllRooms() {
        for room in rooms.values where room.state == .open {
            closeRoom(room.id)
        }
    }

}

// MARK: - COR Command System (functions)
extension ControllerOfRooms {

    /// Submits a command for processing and broadcast.
    /// The command is emitted through the publisher and handled by the processing pipeline.
    public func submit(_ command: CORCommand) {
        commandPublisher.send(command)
        //        commandProcessingQueue.async {
        //            self.commandQueue.append(command)
        //            self.commandPublisher.send(command)
        //        }
    }

    /// - Returns: the controller's type-erased publisher of ``CORCommand`` values.
    ///
    /// External objects can subscribe to this publisher to observe the controller's commands.
    func getCommandPublisher() -> AnyPublisher<CORCommand, Never> {
        commandPublisher.eraseToAnyPublisher()
    }

    /// Connects the publisher to the processing system.
    /// Commands are received, enqueued, and processed sequentially.
    private func setupCORCommandSystemPipeline() {  // startProcessingCORCommands() {
        commandPublisher
            .receive(on: commandProcessingQueue)
            // In Swift's Combine framework, using .sink { [weak self] _ in ... } is the standard way to prevent retain cycles (memory leaks). Since the sink closure is typically stored in a property like cancellables, it creates a strong reference to the object owning it (usually self). Without [weak self], self and the closure would hold onto each other forever, preventing deinit from ever being called.
            .sink { [weak self] command in
                guard let self = self else { return }
                self.commandQueue.append(command)
                self.processNextCommand()
            }
            .store(in: &cancellables)
    }

    /// Processes the next command in FIFO order, if available.
    /// Execution is strictly sequential and runs on `commandProcessingQueue`.
    private func processNextCommand() {
        guard !commandQueue.isEmpty else { return }

        let command = commandQueue.removeFirst()
        handle(command)
    }

    /// Dispatches a ``CORCommand`` to the appropriate handler.
    ///
    /// - Parameters:
    ///     - command: The command to handle.
    private func handle(_ command: CORCommand) {
        switch command.action {
        case .open(let roomID):
            Task { @MainActor in
                openRoom(id: roomID)
            }
        case .close(let roomID):
            closeRoom(roomID)
        }
    }

    /// Attempts to open the room with the specified ``RoomID``.
    ///
    /// If another room is already open, it will be closed first.
    /// Room setup and entity placement must occur on the main actor.
    private func openRoom(id: UUID) {

        Task { @MainActor in

            let room = getRoom(id)

            guard room.state == .closed else { return }

            anyRoomIsLoading = true
            await Task.yield()
            await Task.yield()

            for r in rooms.values where r.state == .open {
                closeRoom(r.id)
            }

            logo1.isEnabled = room.logo1IsVisible
            logo2.isEnabled = room.logo2IsVisible

            room.state = .open
            await room.setupEntity()
            entity.addChild(room.entity)
            room.placePanels()

            post("\(room.prettyName) has opened.")

            // Clear loading after RealityKit's next scene update confirms placement
            onRoomPlacementComplete = {
                self.anyRoomIsLoading = false
            }
        }
    }

    /// Attempts to close the room with the specified ``RoomID``.
    ///
    /// If the room is not currently open, the call is ignored.
    private func closeRoom(_ id: UUID) {

        let room = getRoom(id)

        // Only close a room that is currently open.
        guard room.state == .open else { return }

        // logger.log("Closing \(room.prettyName)...")

        room.state = .closed

        logo1.isEnabled = false
        logo2.isEnabled = false

        room.teardownEntity()

        // post("\(room.prettyName) has closed.")
    }

}

// MARK: - Drag Gesture
extension ControllerOfRooms {

    /// Handles drag gestures applied to the currently open room.
    ///
    /// The gesture is translated into room geometry movement relative
    /// to the camera’s right-direction vector.
    func dragRoom(
        with dragGesture: EntityTargetValue<DragGesture.Value>
    ) {
        // TODO: target a specific room
        guard let room = rooms.values.first(where: { $0.state == .open }) else {
            logger.warning("There are no open rooms. Ignoring the DragGesture.")
            return
        }

        room.roomGeometry.processDragGesture(
            dragGesture,
            //            cameraRightDirectionVector: getCameraRightDirectionVector()
        )

        room.placePanels()
    }

    func resetLastDragPosition() {

        guard let room = rooms.values.first(where: { $0.state == .open }) else {
            logger.warning("There are no open rooms. Ignoring the DragGesture.")
            return
        }

        room.roomGeometry.dragState.lastDragPosition = nil
    }

}

// MARK: COR + ARKitSession
extension ControllerOfRooms {

    /// Starts the ARKit session with all required providers.
    ///
    /// Errors encountered during startup are logged.
    func startARKitSession() {
        Task {
            do {
                try await session.run([worldTracking])
            } catch {
                logger.error("ARKitSession error: \(error)")
            }
        }
    }

    func startHeadTrackingLoop() async {
       while worldTracking.state != .running {
           try? await Task.sleep(nanoseconds: 16_000_000)
       }

       while true {
           guard let room = openRoom,
                 let headTrackingControl = room.headTrackingAutoPlayControl,
                 let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())
           else {
               try? await Task.sleep(nanoseconds: 16_000_000)
               continue
           }

           let headTransform = deviceAnchor.originFromAnchorTransform

           let pairs: [(RoomAttachment, SIMD3<Float>)] = room.panels
               .flatMap { $0.attachmentsManager.getAllAttachments() }
               .filter { if case .youtube = $0.type { return true }; return false }
               .compactMap { attachment in
                   guard let entity = entity.findEntity(named: "\(attachment.id) Entity") else { return nil }
                   return (attachment, entity.position(relativeTo: nil))
               }

           let gazedIndex = findGazedPanel(
               headTransform: headTransform,
               panelPositions: pairs.map { $0.1 },
               autoPlayEnabled: true
           )

           let activeID: UUID? = gazedIndex.map { pairs[$0].0.id }

           await MainActor.run {
               NotificationCenter.default.post(
                   name: .headTrackingUpdated,
                   object: HeadTrackingUpdate(
                       source: headTrackingControl.id,
                       activeID: activeID
                   )
               )
           }

           try? await Task.sleep(nanoseconds: 16_000_000)
       }
    }
}
