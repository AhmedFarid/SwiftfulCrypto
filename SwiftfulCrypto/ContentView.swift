//
//  ContentView.swift
//  SwiftfulCrypto
//
//  Created by Farido on 10/09/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()

            VStack(spacing: 40) {
                Text("Accent Color")
                    .foregroundStyle(Color.theme.accent)

                Text("Secondary Color")
                    .foregroundStyle(Color.theme.secondaryText)

                Text("red Color")
                    .foregroundStyle(Color.theme.red)

                Text("Green Color")
                    .foregroundStyle(Color.theme.green)

            }
            .font(.headline)
        }

    }
}

#Preview {
    ContentView()
}
