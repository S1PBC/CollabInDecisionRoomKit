//
//  Room.swift
//
//  Created by Ella Isgar on 12/12/25.
//

import Foundation
import RealityKit

class Room: Identifiable {

    /// The globally unique identifier of the room.
    let id = UUID()

    /// The geometry that defines the room's moving system of moving (geodesic)
    var roomGeometry: RoomGeometry

    /// The panels in the room.
    let panels: [Panel]

    /// Where the room will appear in the list of available rooms.
    var index: Int

    /// The human-friendly label for this room. Used by RoomButton as the label.
    let prettyName: String

    /// The icon for this room's RoomButton.
    let roomButtonIcon: RoomButtonIcon

    /// The RealityKit entity that is the parent of every panel entity + any other entities in the room.
    var entity: Entity

    /// The state of a room.
    enum RoomState {
        case closed  // "The room is currently closed."
        case open  // "The room is currently open."
        case generic  // "This room is generic. It is not a 'real' room."

        // case inTransition // "The state of the room is in transition."
    }

    /// The current state of the room.
    var state: RoomState

    // MARK: Room Control System

    /// The binding of every RoomControl + Target + TargetAction.
    var bindings: [RoomBinding] = []

    /// A list of every RoomControl in the room. Passed along to the ControlPanelView to build each RoomControl's view.
    var controls: [RoomControl] = []

    // MARK: S1 Industries PBC Logos

    var logo1IsVisible: Bool
    var logo2IsVisible: Bool

    init(
        roomGeometry: RoomGeometry,
        panels: [Panel],
        prettyName: String,
        roomButtonIcon: RoomButtonIcon,
        isGeneric: Bool = false,
        controls: [RoomControl] = [],
        index: Int = 0,
        logo1IsVisible: Bool = true,
        logo2IsVisible: Bool = true
    ) {
        self.roomGeometry = roomGeometry
        self.panels = panels
        self.prettyName = prettyName
        self.roomButtonIcon = roomButtonIcon
        self.entity = Entity()
        self.state = isGeneric ? .generic : .closed
        //        self.controls = controls
        self.index = index
        self.logo1IsVisible = logo1IsVisible
        self.logo2IsVisible = logo2IsVisible
    }
    //
    //    func control(_ id: UUID) -> RoomControl? {
    //        controls.first { $0.id == id }
    //    }

    func placePanels() {

        for panel in panels {

            panel.parametricPosition = roomGeometry.parametricPosition(
                of: panel
            )

            panel.entity.transform = roomGeometry.map1DTo3D(for: panel)

        }
    }

    func teardownEntity() {

        self.entity.removeFromParent()

        for panel in panels {
            panel.teardownEntity()
        }

    }

    @MainActor
    func setupEntity() async {

        self.entity = Entity()
        entity.name =
            "[\(prettyName != "" ? prettyName : id.uuidString)] Room Entity"

        for panel in panels {
            await panel.setupEntity()
            entity.addChild(panel.entity)
        }
    }

    /// Wire together a RoomControl + RoomAttachment + RoomControlTargetAction. This wiring is represented as a RoomBinding.
    func bind(
        control: RoomControl,
        attachment: RoomAttachment,
        intendedAction: RoomControlState
    ) {

        logger.log(
            """
            NEW BINDING:
            - control: \(control.id)
            - target: \(attachment.id)
            - initialState: \(control.state)
            """
        )
        let binding = RoomBinding(
            control: control.id,
            target: attachment.id,
            intendedAction: intendedAction,
            initialState: control.state
        )

        // Let attachment know to listen for this control's notifications
        attachment.bindings.append(binding)

        // If this is a new control, add to controls list ==> control will appear on ControlPanelView
        controls.appendIfMissing(control)

        // Let control know which, if any, panel it is associated with (for grouping in ControlPanelView)
        control.panelIndex = panelIndexOf(attachment.id)

        // Room holds the concrete record of every binding between a RoomControl and a target object.
        bindings.append(binding)
    }

    /// Wire together a RoomControl + Panel + RoomControlTargetAction. This wiring is represented as a RoomBinding.
    func bind(
        control: RoomControl,
        panel: Panel,
        intendedAction: RoomControlState
    ) {

        logger.log(
            """
            NEW BINDING:
            - control: \(control.id)
            - panel: \(panel.index)
            - initialState: \(control.state)
            """
        )

        let binding = RoomBinding(
            control: control.id,
            target: panel.id,
            intendedAction: intendedAction,
            initialState: control.state
        )

        // Let panel know to listen for this control's notifications
        panel.bindings.append(binding)

        // If this is a new control, add to controls list ==> control will appear on ControlPanelView
        controls.appendIfMissing(control)

        // Let control know which, if any, panel it is associated with (for grouping in ControlPanelView)
        control.panelIndex = index

        // Room holds the concrete record of every binding between a RoomControl and a target object.
        bindings.append(binding)
    }

    func panelIndexOf(_ attachmentID: UUID) -> Int {
        for panel in panels {
            if panel.attachmentsManager[attachmentID] != nil {
                return panel.index
            }
        }

        // attachment is not associated with a panel
        return -1
    }

    // Create new attachment and wire to a panel in room.
    @discardableResult
    func addAttachmentTo(
        panelIndex: Int,
        type: RoomAttachment.AttachmentType,
        frameWidth: CGFloat? = nil,
        frameHeight: CGFloat? = nil,
        scale: Float = 1,
        x: Float = 0,
        y: Float = 0,
        z _z: Float? = nil,
        orientation: simd_quatf = simd_quaternion(.pi, [0, 1, 0])
    ) -> RoomAttachment? {

        // get panel we are going to wire the attachment to
        guard let panel = panels.first(where: { $0.index == panelIndex }) else {
            return nil
        }

        let z: Float = _z ?? -(panel.shape.depth / 2) - 0.001

        let position: SIMD3<Float> = [x, y, z]

        let attachment = RoomAttachment(
            type: type,
            frameWidth: frameWidth,
            frameHeight: frameHeight,
            scale: scale,
            position: position,
            orientation: orientation
        )

        // Add the attachment to the panel
        panel.addAttachment(attachment)

        return attachment
    }

    func addVisibilityToggleTo(
        attachment: RoomAttachment,
        notVisibleLabel: String = "Not Visible",
        visibleLabel: String = "Visible",
        initialState: RoomControlUIState = .toggle(false)

    ) {

        // Create a control to toggle the visibility of the attachment.
        let control = RoomControl(
            label: notVisibleLabel,
            altLabel: visibleLabel,
            initialUIState: initialState
        )

        bind(
            control: control,
            attachment: attachment,
            intendedAction: .toggle_visibility(false),
        )
    }

}

// TODO: Delete? Or move somewhere else.
let aGenericRoom = makeGenericRoom(n: 0)

/// Creates a generic room.
func makeGenericRoom(
    n: Int,
    prettyName: String = "A Generic Room",
    roomButtonIcon: RoomButtonIcon = RoomButtonIcon.missing
) -> Room {

    let room = Room(
        roomGeometry: RegularPolygonIncircleRoomGeometry(
            numberOfSides: 0,
            sideLength: 0
        ),
        panels: [],
        prettyName: prettyName,
        roomButtonIcon: roomButtonIcon,
        isGeneric: true
    )

    return room

}

// TODO: Consolidate ID naming convention / generation
extension Room {

    static func generateID() -> String {
        return "ROOM-\(UUID().uuidString)"
    }

}

extension Array where Element: Equatable {
    mutating func appendIfMissing(_ element: Element) {
        if !contains(element) {
            append(element)
        }
    }
}

extension Room {
    // The control, if one exists, that is bound to head-tracked autoplay.
    var headTrackingAutoPlayControl: RoomControl? {
        controls.first { control in
            bindings.contains {
                $0.control == control.id &&
                $0.intendedAction.isSameCase(as: .toggle_headTrackedAutoplay(false))
            }
        }
    }
}
