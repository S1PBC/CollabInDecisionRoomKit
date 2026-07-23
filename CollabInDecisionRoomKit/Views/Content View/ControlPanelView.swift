//
//  ControlPanelView.swift
//
//  Created by Ella Isgar on 11/24/25.
//

import SwiftUI

/// A control panel that is specific to each room.
struct ControlPanelView: View {

    @Environment(COR.self) var cor

    var controls: [RoomControl] {
        // do not attempt to show room-specific controls if no room is open
        guard let room = cor.openRoom else { return [] }
        return room.controls
    }

    var controlsByPanel: [(panelIndex: Int, controls: [RoomControl])] {

        let panelAssociatedControls = controls.filter { $0.panelIndex != -1 }
        let grouped = Dictionary(grouping: panelAssociatedControls) {
            $0.panelIndex
        }
        return
            grouped
            .map { (panelIndex: $0.key, controls: $0.value) }
            .sorted { $0.panelIndex < $1.panelIndex }
    }

    var roomLevelControls: [RoomControl] {

        return controls.filter { $0.panelIndex == -1 }
    }

    var body: some View {

        VStack(spacing: 0) {

            Text("Room-Specific Control Panel")
                .font(.largeTitle)
                .padding()

            ScrollView {

                VStack(
                    alignment: .leading,
                ) {

                    if cor.openRoom != nil {

                        // Panel Sections
                        ForEach(controlsByPanel, id: \.panelIndex) { panel in
                            ControlSectionView(
                                title: "Panel \(panel.panelIndex)"
                            ) {
                                ForEach(panel.controls) { control in
                                    RoomControlView(
                                        control: control
                                    )
                                }
                            }
                        }
                    }

                    //                        // Room-level / debug controls
                    //                        if !roomLevelControls.isEmpty {
                    //                            ControlSectionView(title: "Debug Controls") {
                    //                                ForEach(roomLevelControls) { control in
                    //                                    RoomControlView(
                    //                                        control: control,
                    //                                        actions: cor.openRoom?.actions.filter {
                    //                                            control.actionIDs.contains($0.id)
                    //                                        } ?? []
                    //                                    )
                    //                                }
                    //                            }
                    //                        }

                    else {
                        Text("No room open.")
                            .foregroundStyle(.secondary)
                            .padding()
                    }

                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading,
                )

            }
            .disabled(cor.anyRoomIsLoading)
            .padding()
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .background {
                RoundedRectangle(cornerSize: CGSize(width: 25, height: 25))
                    .fill(Color.black.opacity(0.2))
            }

        }
        .frame(
            maxWidth: 550,
            maxHeight: 350
        )

    }

}

struct ControlSectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            content()
                .padding(.horizontal)
            Divider()
        }
        .padding(.vertical, 4)
    }
}
