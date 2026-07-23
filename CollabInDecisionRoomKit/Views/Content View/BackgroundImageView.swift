//
//  BackgroundImageView.swift
//
//  Created by Ella Isgar on 12/22/25.
//

import SwiftUI

/// The background image of the ContentView.
struct BackgroundImageView: View {

    var body: some View {

        Image("BackgroundImage")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()

    }

}
