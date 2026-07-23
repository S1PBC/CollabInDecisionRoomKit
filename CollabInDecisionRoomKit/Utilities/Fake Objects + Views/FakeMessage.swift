//
//  FakeMessage.swift
//
//  Created by Ella Isgar on 12/4/25.
//

import Foundation
import SwiftUI

/// A fake message that serves as the stand-in UI for the to-be-implemented messages displayed there.
struct FakeMessage: Identifiable {
    let id = UUID()
    let timestamp: Date
    let text: String
}

func makeFakeMessages(_ count: Int) -> [FakeMessage] {
    (0..<count).map { _ in
        FakeMessage(
            timestamp: Date(),
            text: randomString(length: 30)
        )
    }
}

struct FakeMessageView: View {

    var fakeMessage: FakeMessage

    init(_ fakeMessage: FakeMessage) {
        self.fakeMessage = fakeMessage
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(
                fakeMessage.timestamp.formatted(date: .omitted, time: .standard)
            )
            .font(.caption)
            .foregroundStyle(.gray)

            Text(fakeMessage.text)
                .fontWeight(.bold)
                .foregroundStyle(.green)
        }
    }
}
