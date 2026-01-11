//
//  ContentView.swift
//  DF787
//
//  Created by IGOR on 15/12/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameManager = GameManager.shared
    
    var body: some View {
        Group {
            if !gameManager.hasCompletedOnboarding {
                OnboardingView(gameManager: gameManager)
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
            } else {
                MainHubView(gameManager: gameManager)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: gameManager.hasCompletedOnboarding)
    }
}

#Preview {
    ContentView()
}
