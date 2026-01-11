//
//  TimingGateGame.swift
//  DF787
//

import SwiftUI
import Combine

struct TimingGateGame: View {
    let difficulty: Difficulty
    let level: Int
    let onComplete: (LevelResult) -> Void
    
    @State private var gamePhase: GamePhase = .ready
    @State private var gatePositions: [CGFloat] = []
    @State private var indicatorPosition: CGFloat = 0
    @State private var currentGate: Int = 0
    @State private var hits: [Bool] = []
    @State private var isPulsing = false
    @State private var startTime: Date = Date()
    @State private var countdown: Int = 3
    
    private let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    private var gateCount: Int {
        let base = 3
        let difficultyBonus = Difficulty.allCases.firstIndex(of: difficulty)! * 2
        let levelBonus = (level - 1) / 2
        return min(base + difficultyBonus + levelBonus, 10)
    }
    
    private var hitZoneSize: CGFloat {
        let base: CGFloat = 60
        let reduction = CGFloat(Difficulty.allCases.firstIndex(of: difficulty)!) * 10
        let levelReduction = CGFloat((level - 1) / 3) * 5
        return max(base - reduction - levelReduction, 30)
    }
    
    private var speed: CGFloat {
        let base: CGFloat = 2.0
        let speedUp = CGFloat(Difficulty.allCases.firstIndex(of: difficulty)!) * 0.5
        let levelSpeedUp = CGFloat((level - 1) / 2) * 0.3
        return min(base + speedUp + levelSpeedUp, 5.0)
    }
    
    enum GamePhase {
        case ready
        case countdown
        case playing
        case result
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 24) {
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
                
                // Game area
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(AppColors.deepStormBlue.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(AppColors.mutedSteelGray.opacity(0.3), lineWidth: 1)
                        )
                    
                    if gamePhase == .countdown {
                        Text("\(countdown)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.electricGold)
                    } else if gamePhase == .playing || gamePhase == .result {
                        // Gate track
                        GateTrackView(
                            gatePositions: gatePositions,
                            indicatorPosition: indicatorPosition,
                            hitZoneSize: hitZoneSize,
                            currentGate: currentGate,
                            hits: hits,
                            width: geometry.size.width - 80
                        )
                    } else {
                        Image(systemName: "timer")
                            .font(.system(size: 60, weight: .medium))
                            .foregroundColor(AppColors.mutedSteelGray.opacity(0.5))
                    }
                }
                .frame(height: 280)
                .padding(.horizontal, 20)
                
                // Hit results display
                if gamePhase == .playing || gamePhase == .result {
                    HStack(spacing: 8) {
                        ForEach(0..<gateCount, id: \.self) { index in
                            Circle()
                                .fill(hitDotColor(for: index))
                                .frame(width: 12, height: 12)
                        }
                    }
                }
                
                Spacer()
                
                // Action button
                if gamePhase == .ready {
                    PrimaryButton(title: "Start") {
                        startGame()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                } else if gamePhase == .playing {
                    // Large tap button
                    Button {
                        handleTap()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(AppColors.electricGold.opacity(isPulsing ? 0.8 : 0.6))
                                .frame(width: 120, height: 120)
                                .scaleEffect(isPulsing ? 1.1 : 1.0)
                            
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 44, weight: .bold))
                                .foregroundColor(AppColors.deepStormBlueDark)
                        }
                        .glow(color: AppColors.electricGold, radius: isPulsing ? 25 : 15)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 40)
                }
            }
        }
        .onReceive(timer) { _ in
            if gamePhase == .playing {
                updateIndicator()
            }
        }
    }
    
    private var phaseTitle: String {
        switch gamePhase {
        case .ready: return "Timing Gate"
        case .countdown: return "Get Ready"
        case .playing: return "Tap When Aligned"
        case .result: return "Processing..."
        }
    }
    
    private var phaseSubtitle: String {
        switch gamePhase {
        case .ready: return "Release energy at the perfect moment"
        case .countdown: return "Gates appearing in..."
        case .playing: return "Gate \(currentGate + 1) of \(gateCount)"
        case .result: return ""
        }
    }
    
    private func hitDotColor(for index: Int) -> Color {
        if index < hits.count {
            return hits[index] ? AppColors.electricGold : Color.red.opacity(0.7)
        }
        if index == currentGate && gamePhase == .playing {
            return AppColors.coldLightningCyan
        }
        return AppColors.mutedSteelGray.opacity(0.3)
    }
    
    private func startGame() {
        generateGates()
        hits = []
        currentGate = 0
        indicatorPosition = 0
        gamePhase = .countdown
        countdown = 3
        
        runCountdown()
    }
    
    private func runCountdown() {
        guard countdown > 0 else {
            startPlaying()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            countdown -= 1
            runCountdown()
        }
    }
    
    private func generateGates() {
        let spacing: CGFloat = 1.0 / CGFloat(gateCount + 1)
        gatePositions = (1...gateCount).map { CGFloat($0) * spacing }
    }
    
    private func startPlaying() {
        gamePhase = .playing
        startTime = Date()
        indicatorPosition = 0
    }
    
    private func updateIndicator() {
        indicatorPosition += speed / 1000
        
        if indicatorPosition >= 1.0 {
            indicatorPosition = 0
            
            // Check if player missed the current gate
            if currentGate < gateCount {
                hits.append(false)
                currentGate += 1
                
                if currentGate >= gateCount {
                    completeGame()
                }
            }
        }
    }
    
    private func handleTap() {
        guard currentGate < gateCount else { return }
        
        withAnimation(.spring(response: 0.15)) {
            isPulsing = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isPulsing = false
        }
        
        let gatePos = gatePositions[currentGate]
        let distance = abs(indicatorPosition - gatePos)
        let threshold = hitZoneSize / 400 // Convert to 0-1 scale
        
        let isHit = distance <= threshold
        hits.append(isHit)
        currentGate += 1
        
        if currentGate >= gateCount {
            completeGame()
        }
    }
    
    private func completeGame() {
        gamePhase = .result
        let elapsed = Date().timeIntervalSince(startTime)
        let successCount = hits.filter { $0 }.count
        let accuracy = Double(successCount) / Double(gateCount)
        let success = accuracy >= 0.6
        let score = success ? Int(accuracy * 100 * (1 + 1 / max(elapsed / Double(gateCount), 1))) : 0
        
        let result = LevelResult(
            success: success,
            accuracy: accuracy,
            timeElapsed: elapsed,
            score: score
        )
        
        onComplete(result)
    }
}

// MARK: - Gate Track View
struct GateTrackView: View {
    let gatePositions: [CGFloat]
    let indicatorPosition: CGFloat
    let hitZoneSize: CGFloat
    let currentGate: Int
    let hits: [Bool]
    let width: CGFloat
    
    var body: some View {
        ZStack {
            // Track background
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.deepStormBlueDark)
                .frame(width: width, height: 60)
            
            // Gate zones
            ForEach(0..<gatePositions.count, id: \.self) { index in
                GateZone(
                    position: gatePositions[index],
                    hitZoneSize: hitZoneSize,
                    width: width,
                    isActive: index == currentGate,
                    isHit: index < hits.count ? hits[index] : nil
                )
            }
            
            // Moving indicator
            Circle()
                .fill(AppColors.coldLightningCyan)
                .frame(width: 16, height: 16)
                .glow(color: AppColors.coldLightningCyan, radius: 8)
                .offset(x: (indicatorPosition - 0.5) * width)
        }
        .frame(width: width, height: 100)
    }
}

struct GateZone: View {
    let position: CGFloat
    let hitZoneSize: CGFloat
    let width: CGFloat
    let isActive: Bool
    let isHit: Bool?
    
    var body: some View {
        ZStack {
            // Hit zone
            Rectangle()
                .fill(zoneColor.opacity(0.3))
                .frame(width: hitZoneSize, height: 60)
            
            // Gate marker
            Rectangle()
                .fill(zoneColor)
                .frame(width: 4, height: 80)
        }
        .offset(x: (position - 0.5) * width)
    }
    
    private var zoneColor: Color {
        if let hit = isHit {
            return hit ? AppColors.electricGold : Color.red
        }
        return isActive ? AppColors.coldLightningCyan : AppColors.mutedSteelGray.opacity(0.5)
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        TimingGateGame(difficulty: .calm, level: 1) { _ in }
    }
}

