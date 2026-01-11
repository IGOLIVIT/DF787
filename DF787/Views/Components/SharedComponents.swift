//
//  SharedComponents.swift
//  DF787
//

import SwiftUI

// MARK: - Primary Button
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var style: ButtonStyle = .gold
    
    enum ButtonStyle {
        case gold, cyan, outline
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(borderColor, lineWidth: style == .outline ? 2 : 0)
                )
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
    }
    
    private var foregroundColor: Color {
        switch style {
        case .gold: return AppColors.deepStormBlueDark
        case .cyan: return AppColors.deepStormBlueDark
        case .outline: return AppColors.electricGold
        }
    }
    
    private var background: some View {
        Group {
            switch style {
            case .gold:
                AppColors.goldGradient
            case .cyan:
                AppColors.cyanGradient
            case .outline:
                Color.clear
            }
        }
    }
    
    private var borderColor: Color {
        style == .outline ? AppColors.electricGold : .clear
    }
}

// MARK: - Secondary Button
struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                Text(title)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
            }
            .foregroundColor(AppColors.softWhite)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.deepStormBlue.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.mutedSteelGray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Progress Ring
struct ProgressRing: View {
    let progress: Double
    var size: CGFloat = 60
    var lineWidth: CGFloat = 6
    var showPercentage: Bool = true
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    AppColors.mutedSteelGray.opacity(0.2),
                    lineWidth: lineWidth
                )
            
            // Progress ring
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    AppColors.goldGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.5), value: progress)
            
            // Percentage text
            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.softWhite)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Glass Card
struct GlassCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 20
    
    init(padding: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.deepStormBlue.opacity(0.5))
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial.opacity(0.3))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        AppColors.mutedSteelGray.opacity(0.3),
                                        AppColors.mutedSteelGray.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
    }
}

// MARK: - Glow Effect
struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.5), radius: radius / 2)
            .shadow(color: color.opacity(0.3), radius: radius)
    }
}

extension View {
    func glow(color: Color = AppColors.electricGold, radius: CGFloat = 10) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
}

// MARK: - Animated Icon
struct AnimatedIcon: View {
    let systemName: String
    let isActive: Bool
    var activeColor: Color = AppColors.electricGold
    var inactiveColor: Color = AppColors.mutedSteelGray
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 24, weight: .medium))
            .foregroundColor(isActive ? activeColor : inactiveColor)
            .scaleEffect(scale)
            .onChange(of: isActive) { newValue in
                if newValue {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        scale = 1.2
                    }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.1)) {
                        scale = 1.0
                    }
                }
            }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.electricGold)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColors.mutedSteelGray)
                
                Text(value)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.softWhite)
            }
            
            Spacer()
        }
    }
}

// MARK: - Difficulty Badge
struct DifficultyBadge: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(difficulty.rawValue)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? AppColors.deepStormBlueDark : AppColors.softWhite)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? difficulty.color : AppColors.deepStormBlue.opacity(0.5))
                )
                .overlay(
                    Capsule()
                        .stroke(difficulty.color.opacity(isSelected ? 0 : 0.5), lineWidth: 1)
                )
        }
    }
}

// MARK: - Success Overlay
struct SuccessOverlay: View {
    let title: String
    let subtitle: String
    @Binding var isPresented: Bool
    let onDismiss: () -> Void
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .opacity(opacity)
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(AppColors.electricGold.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .fill(AppColors.electricGold)
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppColors.deepStormBlueDark)
                }
                .glow(color: AppColors.electricGold, radius: 20)
                
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.softWhite)
                    
                    Text(subtitle)
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.mutedSteelGray)
                        .multilineTextAlignment(.center)
                }
                
                PrimaryButton(title: "Continue") {
                    withAnimation(.easeOut(duration: 0.3)) {
                        opacity = 0
                        scale = 0.5
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isPresented = false
                        onDismiss()
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 8)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(AppColors.deepStormBlue)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(AppColors.electricGold.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(scale)
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(AppColors.mutedSteelGray.opacity(0.3), lineWidth: 4)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: 0.3)
                        .stroke(AppColors.electricGold, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(rotation))
                }
                
                Text("Loading...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.mutedSteelGray)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

