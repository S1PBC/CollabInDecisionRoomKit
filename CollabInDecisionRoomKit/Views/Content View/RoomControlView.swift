//
//  RoomControlView.swift
//  Rooms
//
//  Created by Ella Isgar on 2/25/26.
//

import SwiftUI

struct RoomControlView: View {

    @Environment(COR.self) var cor

    let control: RoomControl

    var body: some View {

        switch control.state {
        case .button:
            Button {
                control.postUpdatedControlState(.button)
            } label: {
                Text(control.label)
            }
            .buttonStyle(.bordered)
        case .toggle(let isOn):
            let displayLabel = (isOn ? control.altLabel : nil) ?? control.label

            Toggle(
                displayLabel,
                isOn: Binding(
                    get: { isOn },
                    set: { newValue in
                        control.postUpdatedControlState(.toggle(newValue))
                    }
                )
            )
            .toggleStyle(.button)
        }

    }
}
