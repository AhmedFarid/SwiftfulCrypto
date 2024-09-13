//
//  SwiftfulCryptoApp.swift
//  SwiftfulCrypto
//
//  Created by Farido on 10/09/2024.
//

import SwiftUI

@main
struct SwiftfulCryptoApp: App {

    @StateObject private var vm = HomeViewModel()

    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color.theme.accent)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.theme.accent)]
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .toolbar(.automatic, for: .navigationBar)
            }
            .environmentObject(vm)
        }
    }
}
