//
//  FakeControl.swift
//
//  Created by Ella Isgar on 12/4/25.
//

import Foundation
import SwiftUI

/// A fake control that serves as the stand-in UI for the to-be-implemented actual controls per room.
struct FakeControl: Identifiable {
    enum ControlType: CaseIterable {
        case button
        case toggle
        case slider
        case picker
    }

    let id = UUID()
    let label: String
    let type: ControlType
}

func makeFakeControls(_ count: Int) -> [FakeControl] {
    (0..<count).map { _ in
        FakeControl(
            label: randomString(length: Int.random(in: 5..<20)),  // 12),
            type: FakeControl.ControlType.allCases.randomElement()!
        )
    }
}

struct FakeControlView: View {
    let index: Int
    let fakeControl: FakeControl

    @State private var toggleValue = Bool.random()
    @State private var sliderValue = Double.random(in: 0...1)
    @State private var pickerValue = ["A", "B", "C"].randomElement()!

    var body: some View {

        HStack {

            Text("\(index + 1). \(fakeControl.label)")
                .font(.title2)
                .frame(width: 200, alignment: .leading)
                .lineLimit(1)

            Spacer()

            switch fakeControl.type {
            case .button:
                Button("Press Me") {}

            case .toggle:
                Toggle("", isOn: $toggleValue)
                    .labelsHidden()

            case .slider:
                Slider(value: $sliderValue)

            case .picker:
                Picker("", selection: $pickerValue) {
                    Text("A").tag("A")
                    Text("B").tag("B")
                    Text("C").tag("C")
                }
                .pickerStyle(.menu)
                .labelsHidden()
            }
        }

    }
}
