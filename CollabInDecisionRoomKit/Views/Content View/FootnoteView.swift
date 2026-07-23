//
//  FootnoteView.swift
//
//  Created by Ella Isgar on 11/24/25.
//

import SwiftUI

/// The view of the footnote for the ContentView.
struct FootnoteView: View {

    var body: some View {

        VStack {

            Text("Patent Pending")
            
            HStack(spacing: 4) {

                Image(systemName: "c.circle")

                Text("S1 Industries PBC Incorporated and Luis P. Breva. All Rights Reserved. Confidential.")

            }

        }
        .font(.footnote)
        .foregroundColor(.secondary)
        .padding()
    }
    
}
