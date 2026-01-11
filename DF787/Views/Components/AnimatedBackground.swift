//
//  AnimatedBackground.swift
//  DF787
//

import SwiftUI

struct AnimatedBackground: View {
    @State private var phase: CGFloat = 0
    @State private var glowOpacity: Double = 0.3
    
    var body: some View {
        ZStack {
            // Base gradient
            AppColors.backgroundGradient
            
            // Animated glow layers
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppColors.electricGold.opacity(0.15),
                            AppColors.electricGold.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 300
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: sin(phase * 0.5) * 50, y: cos(phase * 0.3) * 30 - 100)
                .opacity(glowOpacity)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppColors.coldLightningCyan.opacity(0.1),
                            AppColors.coldLightningCyan.opacity(0.03),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 250
                    )
                )
                .frame(width: 350, height: 350)
                .offset(x: cos(phase * 0.4) * 40 + 80, y: sin(phase * 0.6) * 40 + 150)
                .opacity(glowOpacity * 0.8)
            
            // Subtle particle effect
            ParticleView()
                .opacity(0.4)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                glowOpacity = 0.5
            }
        }
    }
}

struct ParticleView: View {
    let particleCount = 15
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<particleCount, id: \.self) { index in
                ParticleNode(
                    size: geometry.size,
                    delay: Double(index) * 0.3
                )
            }
        }
    }
}

struct ParticleNode: View {
    let size: CGSize
    let delay: Double
    
    @State private var position: CGPoint = .zero
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        Circle()
            .fill(AppColors.electricGold.opacity(0.6))
            .frame(width: 4, height: 4)
            .scaleEffect(scale)
            .opacity(opacity)
            .position(position)
            .onAppear {
                position = CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: size.height + 20
                )
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    animateParticle()
                }
            }
    }
    
    private func animateParticle() {
        let duration = Double.random(in: 8...15)
        
        withAnimation(.easeOut(duration: 1)) {
            opacity = Double.random(in: 0.3...0.7)
            scale = CGFloat.random(in: 0.8...1.2)
        }
        
        withAnimation(.linear(duration: duration)) {
            position = CGPoint(
                x: position.x + CGFloat.random(in: -50...50),
                y: -20
            )
        }
        
        withAnimation(.easeIn(duration: 2).delay(duration - 2)) {
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.5) {
            position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: size.height + 20
            )
            animateParticle()
        }
    }
}

