//
//  OnboardingView.swift
//  DF787
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var gameManager: GameManager
    @State private var currentPage = 0
    @State private var isAnimating = false
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "waveform.path.ecg",
            title: "Control the Rhythm",
            description: "Master the flow of energy through precision and timing. Every action counts."
        ),
        OnboardingPage(
            icon: "eye.fill",
            title: "Anticipate the Pattern",
            description: "Observe, analyze, and predict. Sharpen your mind to see what comes next."
        ),
        OnboardingPage(
            icon: "bolt.horizontal.fill",
            title: "Master the Sequence",
            description: "Progress through challenges that evolve with your skill. Become unstoppable."
        ),
        OnboardingPage(
            icon: "crown.fill",
            title: "Rise Through the Ranks",
            description: "Earn titles, unlock achievements, and prove your mastery over controlled chaos."
        )
    ]
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page, isActive: currentPage == index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)
                
                Spacer()
                
                // Page indicator
                HStack(spacing: 10) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? AppColors.electricGold : AppColors.mutedSteelGray.opacity(0.5))
                            .frame(width: currentPage == index ? 10 : 8, height: currentPage == index ? 10 : 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 32)
                
                // Navigation buttons
                VStack(spacing: 12) {
                    if currentPage == pages.count - 1 {
                        PrimaryButton(title: "Begin") {
                            withAnimation {
                                gameManager.hasCompletedOnboarding = true
                            }
                        }
                    } else {
                        PrimaryButton(title: "Continue") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                    }
                    
                    if currentPage < pages.count - 1 {
                        Button {
                            withAnimation {
                                gameManager.hasCompletedOnboarding = true
                            }
                        } label: {
                            Text("Skip")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.mutedSteelGray)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool
    
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var textOffset: CGFloat = 30
    @State private var textOpacity: Double = 0
    @State private var glowIntensity: Double = 0
    
    var body: some View {
        VStack(spacing: 40) {
            // Icon with glow
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppColors.electricGold.opacity(0.4 * glowIntensity),
                                AppColors.electricGold.opacity(0.1 * glowIntensity),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 120
                        )
                    )
                    .frame(width: 200, height: 200)
                
                // Icon background
                Circle()
                    .fill(AppColors.deepStormBlue)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(AppColors.electricGold.opacity(0.5), lineWidth: 2)
                    )
                
                // Icon
                Image(systemName: page.icon)
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(AppColors.electricGold)
            }
            .scaleEffect(iconScale)
            .opacity(iconOpacity)
            
            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.softWhite)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(AppColors.mutedSteelGray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
            }
            .offset(y: textOffset)
            .opacity(textOpacity)
        }
        .padding(.horizontal, 20)
        .onChange(of: isActive) { newValue in
            if newValue {
                animateIn()
            } else {
                resetAnimation()
            }
        }
        .onAppear {
            if isActive {
                animateIn()
            }
        }
    }
    
    private func animateIn() {
        iconScale = 0.5
        iconOpacity = 0
        textOffset = 30
        textOpacity = 0
        glowIntensity = 0
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
            textOffset = 0
            textOpacity = 1.0
        }
        
        withAnimation(.easeInOut(duration: 1.5).delay(0.3)) {
            glowIntensity = 1.0
        }
    }
    
    private func resetAnimation() {
        withAnimation(.easeOut(duration: 0.2)) {
            iconOpacity = 0
            textOpacity = 0
        }
    }
}

#Preview {
    OnboardingView(gameManager: GameManager.shared)
}

