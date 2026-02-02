//
//  PatternSurgeGame.swift
//  DF787
//

import SwiftUI

struct PatternSurgeGame: View {
    let difficulty: Difficulty
    let level: Int
    let onComplete: (LevelResult) -> Void
    
    @State private var gamePhase: GamePhase = .ready
    @State private var pattern: [Int] = []
    @State private var playerInput: [Int] = []
    @State private var activeSymbol: Int? = nil
    @State private var errorSymbol: Int? = nil
    @State private var startTime: Date = Date()
    @State private var countdown: Int = 3
    @State private var showingSymbolIndex: Int = 0
    
    private let symbols = ["bolt.fill", "sparkles", "star.fill", "hexagon.fill", "triangle.fill", "circle.fill"]
    
    private var patternLength: Int {
        let base = 3
        let difficultyBonus = Difficulty.allCases.firstIndex(of: difficulty)! * 2
        let levelBonus = (level - 1) / 2
        return min(base + difficultyBonus + levelBonus, 8)
    }
    
    private var displayTime: Double {
        0.8 * difficulty.speedMultiplier
    }
    
    private var symbolCount: Int {
        min(4 + level / 3, 6)
    }
    
    enum GamePhase {
        case ready
        case countdown
        case showing
        case input
        case result
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Game info
            VStack(spacing: 8) {
                Text(phaseTitle)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.softWhite)
                
                Text(phaseSubtitle)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.mutedSteelGray)
            }
            
            // Pattern display area
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppColors.deepStormBlue.opacity(0.5))
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(AppColors.mutedSteelGray.opacity(0.3), lineWidth: 1)
                    )
                
                if gamePhase == .countdown {
                    Text("\(countdown)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.electricGold)
                        .transition(.scale.combined(with: .opacity))
                } else if gamePhase == .showing, let active = activeSymbol {
                    Image(systemName: symbols[active])
                        .font(.system(size: 80, weight: .medium))
                        .foregroundColor(AppColors.electricGold)
                        .glow(color: AppColors.electricGold, radius: 20)
                        .transition(.scale.combined(with: .opacity))
                } else if gamePhase == .input {
                    // Progress indicator
                    HStack(spacing: 8) {
                        ForEach(0..<patternLength, id: \.self) { index in
                            Circle()
                                .fill(dotColor(for: index))
                                .frame(width: 12, height: 12)
                        }
                    }
                } else if gamePhase == .ready {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 60, weight: .medium))
                        .foregroundColor(AppColors.mutedSteelGray.opacity(0.5))
                }
            }
            .padding(.horizontal, 20)
            .animation(.spring(response: 0.3), value: activeSymbol)
            .animation(.spring(response: 0.3), value: gamePhase)
            
            // Symbol buttons
            if gamePhase == .input {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                    ForEach(0..<symbolCount, id: \.self) { index in
                        SymbolButton(
                            symbol: symbols[index],
                            isError: errorSymbol == index,
                            action: {
                                handleSymbolTap(index)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            } else {
                // Placeholder for layout
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                    ForEach(0..<symbolCount, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.deepStormBlue.opacity(0.3))
                            .frame(height: 80)
                    }
                }
                .padding(.horizontal, 20)
                .opacity(0.5)
            }
            
            Spacer()
            
            // Start button
            if gamePhase == .ready {
                PrimaryButton(title: "Start") {
                    startGame()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
    
    private var phaseTitle: String {
        switch gamePhase {
        case .ready: return "Pattern Surge"
        case .countdown: return "Get Ready"
        case .showing: return "Watch Carefully"
        case .input: return "Reproduce the Pattern"
        case .result: return "Complete!"
        }
    }
    
    private var phaseSubtitle: String {
        switch gamePhase {
        case .ready: return "Remember and reproduce the sequence"
        case .countdown: return "Pattern starts in..."
        case .showing: return "Showing \(showingSymbolIndex + 1) of \(patternLength)"
        case .input: return "\(playerInput.count) of \(patternLength) entered"
        case .result: return "Complete!"
        }
    }
    
    private func dotColor(for index: Int) -> Color {
        if index < playerInput.count {
            return AppColors.electricGold
        }
        return AppColors.mutedSteelGray.opacity(0.3)
    }
    
    private func startGame() {
        generatePattern()
        gamePhase = .countdown
        countdown = 3
        
        runCountdown()
    }
    
    private func runCountdown() {
        guard countdown > 0 else {
            showPattern()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            countdown -= 1
            runCountdown()
        }
    }
    
    private func generatePattern() {
        pattern = (0..<patternLength).map { _ in
            Int.random(in: 0..<symbolCount)
        }
    }
    
    private func showPattern() {
        gamePhase = .showing
        showingSymbolIndex = 0
        showNextSymbol()
    }
    
    private func showNextSymbol() {
        guard showingSymbolIndex < pattern.count else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                startInputPhase()
            }
            return
        }
        
        activeSymbol = pattern[showingSymbolIndex]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + displayTime) {
            activeSymbol = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showingSymbolIndex += 1
                showNextSymbol()
            }
        }
    }
    
    private func startInputPhase() {
        gamePhase = .input
        playerInput = []
        startTime = Date()
    }
    
    private func handleSymbolTap(_ index: Int) {
        let expectedSymbol = pattern[playerInput.count]
        
        if index == expectedSymbol {
            playerInput.append(index)
            
            if playerInput.count == pattern.count {
                completeGame(success: true)
            }
        } else {
            errorSymbol = index
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                errorSymbol = nil
                completeGame(success: false)
            }
        }
    }
    
    private func completeGame(success: Bool) {
        gamePhase = .result
        let elapsed = Date().timeIntervalSince(startTime)
        let accuracy = success ? Double(playerInput.count) / Double(pattern.count) : Double(playerInput.count) / Double(pattern.count + 1)
        let score = success ? Int(accuracy * 100 * (1 + 1 / max(elapsed, 1))) : 0
        
        let result = LevelResult(
            success: success,
            accuracy: accuracy,
            timeElapsed: elapsed,
            score: score
        )
        
        onComplete(result)
    }
}

struct SymbolButton: View {
    let symbol: String
    let isError: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(isError ? Color.red.opacity(0.3) : AppColors.deepStormBlue.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isError ? Color.red : AppColors.electricGold.opacity(0.5), lineWidth: isError ? 2 : 1)
                    )
                    .frame(height: 80)
                
                Image(systemName: symbol)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(isError ? Color.red : AppColors.electricGold)
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        PatternSurgeGame(difficulty: .calm, level: 1) { _ in }
    }
}

