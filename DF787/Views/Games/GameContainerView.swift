//
//  GameContainerView.swift
//  DF787
//

import SwiftUI

struct GameContainerView: View {
    let gameType: GameType
    let difficulty: Difficulty
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentLevel: Int = 1
    @State private var showingResult = false
    @State private var lastResult: LevelResult?
    @State private var isGameActive = true
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: 0) {
                // Header
                GameHeader(
                    gameType: gameType,
                    difficulty: difficulty,
                    currentLevel: currentLevel,
                    totalLevels: difficulty.levels,
                    onClose: {
                        dismiss()
                    }
                )
                
                // Game content
                Group {
                    switch gameType {
                    case .patternSurge:
                        PatternSurgeGame(
                            difficulty: difficulty,
                            level: currentLevel,
                            onComplete: handleGameComplete
                        )
                    case .timingGate:
                        TimingGateGame(
                            difficulty: difficulty,
                            level: currentLevel,
                            onComplete: handleGameComplete
                        )
                    case .signalDivide:
                        SignalDivideGame(
                            difficulty: difficulty,
                            level: currentLevel,
                            onComplete: handleGameComplete
                        )
                    }
                }
                .id("\(currentLevel)-\(isGameActive)")
            }
            
            // Result overlay
            if showingResult, let result = lastResult {
                GameResultOverlay(
                    result: result,
                    currentLevel: currentLevel,
                    totalLevels: difficulty.levels,
                    onContinue: {
                        if result.success && currentLevel < difficulty.levels {
                            currentLevel += 1
                            isGameActive.toggle()
                        }
                        showingResult = false
                    },
                    onExit: {
                        dismiss()
                    }
                )
            }
        }
    }
    
    private func handleGameComplete(_ result: LevelResult) {
        lastResult = result
        // Show overlay first so it's visible on iPad before any GameManager re-renders
        showingResult = true
        gameManager.updateProgress(for: gameType, difficulty: difficulty, level: currentLevel, result: result)
    }
}

// MARK: - Game Header
struct GameHeader: View {
    let gameType: GameType
    let difficulty: Difficulty
    let currentLevel: Int
    let totalLevels: Int
    let onClose: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.softWhite)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(AppColors.deepStormBlue.opacity(0.6))
                    )
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text(gameType.rawValue)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.softWhite)
                
                Text("Level \(currentLevel) of \(totalLevels)")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.mutedSteelGray)
            }
            
            Spacer()
            
            // Difficulty badge
            Text(difficulty.rawValue)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppColors.deepStormBlueDark)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(difficulty.color)
                )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(AppColors.deepStormBlueDark.opacity(0.8))
        )
    }
}

// MARK: - Game Result Overlay
struct GameResultOverlay: View {
    let result: LevelResult
    let currentLevel: Int
    let totalLevels: Int
    let onContinue: () -> Void
    let onExit: () -> Void
    
    // Start visible so overlay always shows on iPad (onAppear can be unreliable in fullScreenCover)
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    private var isComplete: Bool {
        currentLevel >= totalLevels && result.success
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .opacity(opacity)
            
            VStack(spacing: 24) {
                // Result icon
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .fill(iconBackgroundColor)
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: result.success ? "checkmark" : "xmark")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(AppColors.deepStormBlueDark)
                }
                .glow(color: iconBackgroundColor, radius: 15)
                
                // Result text
                VStack(spacing: 8) {
                    Text(titleText)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.softWhite)
                    
                    if result.success {
                        Text("Accuracy: \(Int(result.accuracy * 100))%")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.mutedSteelGray)
                    } else {
                        Text("Keep practicing to improve")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.mutedSteelGray)
                    }
                }
                
                // Score display
                if result.success {
                    HStack(spacing: 30) {
                        ResultStat(title: "Score", value: "\(result.score)", icon: "star.fill")
                        ResultStat(title: "Time", value: formatTime(result.timeElapsed), icon: "clock.fill")
                    }
                }
                
                // Buttons
                VStack(spacing: 12) {
                    if result.success && !isComplete {
                        PrimaryButton(title: "Next Level") {
                            withAnimation(.easeOut(duration: 0.2)) {
                                opacity = 0
                                scale = 0.5
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onContinue()
                            }
                        }
                    } else if isComplete {
                        PrimaryButton(title: "Complete") {
                            onExit()
                        }
                    } else {
                        PrimaryButton(title: "Try Again") {
                            withAnimation(.easeOut(duration: 0.2)) {
                                opacity = 0
                                scale = 0.5
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onContinue()
                            }
                        }
                    }
                    
                    SecondaryButton(title: "Exit", icon: "arrow.left") {
                        onExit()
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(AppColors.deepStormBlue)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(iconBackgroundColor.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(scale)
            .padding(.horizontal, 24)
        }
        .onAppear {
            // Subtle entrance; overlay already visible (avoids infinite "Processing..." on iPad if onAppear didn't run)
            scale = 0.98
            opacity = 0.98
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
    
    private var iconBackgroundColor: Color {
        result.success ? AppColors.electricGold : AppColors.coldLightningCyan
    }
    
    private var titleText: String {
        if isComplete {
            return "Challenge Complete!"
        }
        return result.success ? "Level Cleared!" : "Level Failed"
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
        return "\(seconds).\(milliseconds)s"
    }
}

struct ResultStat: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.electricGold)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.softWhite)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(AppColors.mutedSteelGray)
        }
    }
}

