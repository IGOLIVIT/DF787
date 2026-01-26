//
//  SignalDivideGame.swift
//  DF787
//

import SwiftUI

struct SignalDivideGame: View {
    let difficulty: Difficulty
    let level: Int
    let onComplete: (LevelResult) -> Void
    
    @State private var gamePhase: GamePhase = .ready
    @State private var currentRule: SignalRule = .color
    @State private var signals: [Signal] = []
    @State private var currentSignalIndex: Int = 0
    @State private var correctSorts: Int = 0
    @State private var startTime: Date = Date()
    @State private var countdown: Int = 3
    @State private var ruleDisplayTime: Int = 3
    @State private var errorZone: Int? = nil
    @State private var successAnimation: Bool = false
    
    private var signalCount: Int {
        let base = 5
        let difficultyBonus = Difficulty.allCases.firstIndex(of: difficulty)! * 3
        let levelBonus = (level - 1)
        return min(base + difficultyBonus + levelBonus, 15)
    }
    
    enum GamePhase {
        case ready
        case showingRule
        case countdown
        case playing
        case result
    }
    
    enum SignalRule: String, CaseIterable {
        case color = "Sort by Color"
        case shape = "Sort by Shape"
        case size = "Sort by Size"
        
        var leftZoneLabel: String {
            switch self {
            case .color: return "Gold"
            case .shape: return "Round"
            case .size: return "Small"
            }
        }
        
        var rightZoneLabel: String {
            switch self {
            case .color: return "Cyan"
            case .shape: return "Angular"
            case .size: return "Large"
            }
        }
        
        var instruction: String {
            switch self {
            case .color: return "Gold signals go LEFT, Cyan signals go RIGHT"
            case .shape: return "Round shapes go LEFT, Angular shapes go RIGHT"
            case .size: return "Small signals go LEFT, Large signals go RIGHT"
            }
        }
    }
    
    struct Signal: Identifiable {
        let id = UUID()
        let color: SignalColor
        let shape: SignalShape
        let size: SignalSize
        
        enum SignalColor {
            case gold, cyan
            
            var color: Color {
                switch self {
                case .gold: return AppColors.electricGold
                case .cyan: return AppColors.coldLightningCyan
                }
            }
            
            var name: String {
                switch self {
                case .gold: return "Gold"
                case .cyan: return "Cyan"
                }
            }
        }
        
        enum SignalShape: String {
            case circle = "circle.fill"
            case square = "square.fill"
            case triangle = "triangle.fill"
            case hexagon = "hexagon.fill"
            
            var isRound: Bool {
                self == .circle || self == .hexagon
            }
        }
        
        enum SignalSize {
            case small, large
            
            var scale: CGFloat {
                switch self {
                case .small: return 0.7
                case .large: return 1.3
                }
            }
        }
        
        func belongsToLeft(for rule: SignalRule) -> Bool {
            switch rule {
            case .color: return color == .gold
            case .shape: return shape.isRound
            case .size: return size == .small
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            // Game info
            VStack(spacing: 8) {
                Text(phaseTitle)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.softWhite)
                
                Text(phaseSubtitle)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.mutedSteelGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Rule display during game
            if gamePhase == .showingRule || gamePhase == .playing {
                VStack(spacing: 8) {
                    Text(currentRule.rawValue)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.electricGold)
                    
                    Text(currentRule.instruction)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.mutedSteelGray)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.deepStormBlue.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.electricGold.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
            }
            
            // Game area
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppColors.deepStormBlue.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(AppColors.mutedSteelGray.opacity(0.3), lineWidth: 1)
                    )
                
                if gamePhase == .showingRule {
                    VStack(spacing: 16) {
                        Text("\(ruleDisplayTime)")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.electricGold)
                        
                        Text("Memorize the rule!")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppColors.softWhite)
                    }
                } else if gamePhase == .countdown {
                    Text("\(countdown)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.electricGold)
                } else if gamePhase == .playing && currentSignalIndex < signals.count {
                    // Current signal display
                    VStack(spacing: 20) {
                        // Signal visualization
                        ZStack {
                            Circle()
                                .fill(AppColors.deepStormBlue)
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Circle()
                                        .stroke(signals[currentSignalIndex].color.color, lineWidth: 4)
                                )
                                .shadow(color: signals[currentSignalIndex].color.color.opacity(0.5), radius: 15)
                            
                            Image(systemName: signals[currentSignalIndex].shape.rawValue)
                                .font(.system(size: 48 * signals[currentSignalIndex].size.scale, weight: .medium))
                                .foregroundColor(signals[currentSignalIndex].color.color)
                        }
                        .scaleEffect(successAnimation ? 0.8 : 1.0)
                        .opacity(successAnimation ? 0.5 : 1.0)
                        
                        // Signal info
                        Text("Color: \(signals[currentSignalIndex].color.name)")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.mutedSteelGray)
                    }
                } else if gamePhase == .ready {
                    VStack(spacing: 16) {
                        Image(systemName: "arrow.triangle.branch")
                            .font(.system(size: 60, weight: .medium))
                            .foregroundColor(AppColors.mutedSteelGray.opacity(0.5))
                        
                        Text("Sort signals into correct zones")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.mutedSteelGray)
                    }
                }
            }
            .frame(height: 220)
            .padding(.horizontal, 20)
            
            // Progress indicator
            if gamePhase == .playing {
                HStack(spacing: 6) {
                    ForEach(0..<signalCount, id: \.self) { index in
                        Circle()
                            .fill(progressDotColor(for: index))
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Sorting buttons
            if gamePhase == .playing && currentSignalIndex < signals.count {
                HStack(spacing: 20) {
                    // Left zone button
                    SortButton(
                        label: currentRule.leftZoneLabel,
                        color: AppColors.electricGold,
                        isError: errorZone == 0,
                        icon: "arrow.left"
                    ) {
                        handleSort(isLeft: true)
                    }
                    
                    // Right zone button
                    SortButton(
                        label: currentRule.rightZoneLabel,
                        color: AppColors.coldLightningCyan,
                        isError: errorZone == 1,
                        icon: "arrow.right"
                    ) {
                        handleSort(isLeft: false)
                    }
                }
                .padding(.horizontal, 20)
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
        case .ready: return "Signal Divide"
        case .showingRule: return "Learn the Rule"
        case .countdown: return "Get Ready!"
        case .playing: return "Tap the Correct Zone"
        case .result: return "Complete!"
        }
    }
    
    private var phaseSubtitle: String {
        switch gamePhase {
        case .ready: return "Sort incoming signals based on the rule"
        case .showingRule: return "Remember which signals go where"
        case .countdown: return "Signals incoming..."
        case .playing: return "Signal \(currentSignalIndex + 1) of \(signalCount)"
        case .result: return "Loading results..."
        }
    }
    
    private func progressDotColor(for index: Int) -> Color {
        if index < currentSignalIndex {
            return AppColors.electricGold
        }
        if index == currentSignalIndex {
            return AppColors.coldLightningCyan
        }
        return AppColors.mutedSteelGray.opacity(0.3)
    }
    
    private func startGame() {
        generateSignals()
        selectRule()
        currentSignalIndex = 0
        correctSorts = 0
        gamePhase = .showingRule
        ruleDisplayTime = 3
        
        runRuleDisplay()
    }
    
    private func selectRule() {
        // Select rule based on level
        let availableRules: [SignalRule]
        switch level {
        case 1...2: availableRules = [.color]
        case 3...4: availableRules = [.color, .shape]
        default: availableRules = SignalRule.allCases
        }
        currentRule = availableRules.randomElement() ?? .color
    }
    
    private func generateSignals() {
        signals = (0..<signalCount).map { _ in
            Signal(
                color: Bool.random() ? .gold : .cyan,
                shape: [.circle, .square, .triangle, .hexagon].randomElement()!,
                size: Bool.random() ? .small : .large
            )
        }
    }
    
    private func runRuleDisplay() {
        guard ruleDisplayTime > 0 else {
            gamePhase = .countdown
            countdown = 3
            runCountdown()
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            ruleDisplayTime -= 1
            runRuleDisplay()
        }
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
    
    private func startPlaying() {
        gamePhase = .playing
        startTime = Date()
    }
    
    private func handleSort(isLeft: Bool) {
        guard currentSignalIndex < signals.count else { return }
        
        let signal = signals[currentSignalIndex]
        let correctChoice = signal.belongsToLeft(for: currentRule)
        
        if isLeft == correctChoice {
            // Correct!
            correctSorts += 1
            
            withAnimation(.easeOut(duration: 0.2)) {
                successAnimation = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                successAnimation = false
                currentSignalIndex += 1
                
                if currentSignalIndex >= signals.count {
                    completeGame()
                }
            }
        } else {
            // Wrong!
            errorZone = isLeft ? 0 : 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                errorZone = nil
                currentSignalIndex += 1
                
                if currentSignalIndex >= signals.count {
                    completeGame()
                }
            }
        }
    }
    
    private func completeGame() {
        gamePhase = .result
        let elapsed = Date().timeIntervalSince(startTime)
        let accuracy = Double(correctSorts) / Double(signalCount)
        let success = accuracy >= 0.6
        let score = success ? Int(accuracy * 100 * (1 + 1 / max(elapsed / Double(signalCount), 1))) : 0
        
        let result = LevelResult(
            success: success,
            accuracy: accuracy,
            timeElapsed: elapsed,
            score: score
        )
        
        onComplete(result)
    }
}

// MARK: - Sort Button
struct SortButton: View {
    let label: String
    let color: Color
    let isError: Bool
    let icon: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.15)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .bold))
                
                Text(label)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(isError ? Color.red : color)
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(buttonColor.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(buttonColor, lineWidth: 3)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var buttonColor: Color {
        isError ? Color.red : color
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        SignalDivideGame(difficulty: .calm, level: 1) { _ in }
    }
}
