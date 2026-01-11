//
//  MainHubView.swift
//  DF787
//

import SwiftUI

struct MainHubView: View {
    @ObservedObject var gameManager: GameManager
    @State private var selectedTab: Tab = .games
    
    enum Tab: String, CaseIterable {
        case games = "Games"
        case achievements = "Achievements"
        case stats = "Stats"
        
        var icon: String {
            switch self {
            case .games: return "gamecontroller.fill"
            case .achievements: return "trophy.fill"
            case .stats: return "chart.bar.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            VStack(spacing: 0) {
                // Content
                TabView(selection: $selectedTab) {
                    GamesHubView(gameManager: gameManager)
                        .tag(Tab.games)
                    
                    AchievementsView(gameManager: gameManager)
                        .tag(Tab.achievements)
                    
                    StatisticsView(gameManager: gameManager)
                        .tag(Tab.stats)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Custom Tab Bar
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: MainHubView.Tab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainHubView.Tab.allCases, id: \.rawValue) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(
            Rectangle()
                .fill(AppColors.deepStormBlueDark.opacity(0.95))
                .overlay(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppColors.mutedSteelGray.opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 1),
                    alignment: .top
                )
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

struct TabBarButton: View {
    let tab: MainHubView.Tab
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppColors.electricGold : AppColors.mutedSteelGray)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(tab.rawValue)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? AppColors.electricGold : AppColors.mutedSteelGray)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Motivational Quote View
struct MotivationalQuoteView: View {
    @State private var currentQuoteIndex: Int = 0
    @State private var opacity: Double = 1.0
    
    private let quotes = [
        "Master the rhythm of chaos.",
        "Precision is power.",
        "Focus shapes destiny.",
        "Every pattern has a key.",
        "Timing is everything.",
        "Rise through discipline.",
        "Clarity conquers complexity.",
        "Your mind is your weapon.",
        "Progress, not perfection.",
        "Control what you can.",
        "Silence the noise within.",
        "Sharpen your instincts.",
        "Flow with intention.",
        "Challenge breeds strength.",
        "Embrace the storm."
    ]
    
    var body: some View {
        Text(quotes[currentQuoteIndex])
            .font(.system(size: 15, weight: .medium, design: .rounded))
            .foregroundColor(AppColors.electricGold)
            .opacity(opacity)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .onAppear {
                currentQuoteIndex = Int.random(in: 0..<quotes.count)
                startQuoteRotation()
            }
    }
    
    private func startQuoteRotation() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            withAnimation(.easeOut(duration: 0.4)) {
                opacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                var newIndex = Int.random(in: 0..<quotes.count)
                while newIndex == currentQuoteIndex && quotes.count > 1 {
                    newIndex = Int.random(in: 0..<quotes.count)
                }
                currentQuoteIndex = newIndex
                
                withAnimation(.easeIn(duration: 0.4)) {
                    opacity = 1
                }
            }
        }
    }
}

// MARK: - Games Hub View
struct GamesHubView: View {
    @ObservedObject var gameManager: GameManager
    @State private var selectedGame: GameType?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background that extends to edges
                AppColors.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Motivational quote at top
                        MotivationalQuoteView()
                            .padding(.top, 20)
                        
                        // Header with player info
                        PlayerProgressCard(gameManager: gameManager)
                            .padding(.horizontal, 20)
                        
                        // Games section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Challenges")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.softWhite)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 16) {
                                ForEach(GameType.allCases) { gameType in
                                    NavigationLink(destination: GameDetailView(gameType: gameType, gameManager: gameManager)) {
                                        GameCard(gameType: gameType, gameManager: gameManager)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Player Progress Card
struct PlayerProgressCard: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        GlassCard {
            HStack(spacing: 20) {
                // Rank icon
                ZStack {
                    Circle()
                        .fill(AppColors.electricGold.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: rankIcon)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(AppColors.electricGold)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(gameManager.currentRank.rawValue)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.softWhite)
                    
                    if let nextRank = gameManager.currentRank.next {
                        HStack(spacing: 8) {
                            Text("\(levelsToNext) levels to \(nextRank.rawValue)")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.mutedSteelGray)
                        }
                    } else {
                        Text("Maximum rank achieved")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.electricGold)
                    }
                }
                
                Spacer()
                
                // Overall progress
                ProgressRing(
                    progress: gameManager.overallProgress(),
                    size: 54,
                    lineWidth: 5
                )
            }
        }
    }
    
    private var rankIcon: String {
        switch gameManager.currentRank {
        case .initiate: return "circle.hexagongrid"
        case .apprentice: return "bolt.circle"
        case .adept: return "bolt.circle.fill"
        case .keeper: return "shield.fill"
        case .warden: return "shield.checkered"
        case .master: return "star.fill"
        case .arcMaster: return "crown"
        case .stormSovereign: return "crown.fill"
        }
    }
    
    private var levelsToNext: Int {
        guard let nextRank = gameManager.currentRank.next else { return 0 }
        return max(0, nextRank.requiredLevels - gameManager.playerStats.totalLevelsCompleted)
    }
}

// MARK: - Game Card
struct GameCard: View {
    let gameType: GameType
    @ObservedObject var gameManager: GameManager
    
    @State private var isPressed = false
    
    var body: some View {
        GlassCard(padding: 0) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(AppColors.electricGold.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: gameType.icon)
                        .font(.system(size: 26, weight: .medium))
                        .foregroundColor(AppColors.electricGold)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(gameType.rawValue)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.softWhite)
                    
                    Text(gameType.description)
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.mutedSteelGray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Progress
                VStack(alignment: .trailing, spacing: 4) {
                    ProgressRing(
                        progress: gameManager.gameOverallProgress(for: gameType),
                        size: 44,
                        lineWidth: 4,
                        showPercentage: true
                    )
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.mutedSteelGray)
                }
            }
            .padding(16)
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3), value: isPressed)
    }
}

// MARK: - Game Detail View
struct GameDetailView: View {
    let gameType: GameType
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDifficulty: Difficulty = .calm
    @State private var showingGame = false
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(AppColors.electricGold.opacity(0.15))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: gameType.icon)
                                .font(.system(size: 44, weight: .medium))
                                .foregroundColor(AppColors.electricGold)
                        }
                        .glow(color: AppColors.electricGold, radius: 15)
                        
                        Text(gameType.rawValue)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.softWhite)
                        
                        Text(gameType.detailedDescription)
                            .font(.system(size: 15))
                            .foregroundColor(AppColors.mutedSteelGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    
                    // Difficulty selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select Difficulty")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.softWhite)
                        
                        HStack(spacing: 12) {
                            ForEach(Difficulty.allCases, id: \.rawValue) { difficulty in
                                DifficultyBadge(
                                    difficulty: difficulty,
                                    isSelected: selectedDifficulty == difficulty
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedDifficulty = difficulty
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Level progress
                    LevelProgressView(
                        gameType: gameType,
                        difficulty: selectedDifficulty,
                        gameManager: gameManager
                    )
                    .padding(.horizontal, 20)
                    
                    // Start button
                    PrimaryButton(title: "Start Challenge") {
                        showingGame = true
                        gameManager.recordSession()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(AppColors.electricGold)
                }
            }
        }
        .fullScreenCover(isPresented: $showingGame) {
            GameContainerView(
                gameType: gameType,
                difficulty: selectedDifficulty,
                gameManager: gameManager
            )
        }
    }
}

// MARK: - Level Progress View
struct LevelProgressView: View {
    let gameType: GameType
    let difficulty: Difficulty
    @ObservedObject var gameManager: GameManager
    
    private var progress: GameProgress {
        gameManager.getProgress(for: gameType, difficulty: difficulty)
    }
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Progress")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.softWhite)
                    
                    Spacer()
                    
                    Text("\(progress.completedLevels.count)/\(difficulty.levels) Levels")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.mutedSteelGray)
                }
                
                // Level indicators
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 5), spacing: 10) {
                    ForEach(1...difficulty.levels, id: \.self) { level in
                        LevelIndicator(
                            level: level,
                            isCompleted: progress.completedLevels.contains(level),
                            isCurrent: level == progress.currentLevel
                        )
                    }
                }
                
                // Stats
                if progress.completedLevels.count > 0 {
                    Divider()
                        .background(AppColors.mutedSteelGray.opacity(0.3))
                    
                    HStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Best Accuracy")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.mutedSteelGray)
                            Text("\(Int(progress.bestAccuracy * 100))%")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.electricGold)
                        }
                        
                        if let bestTime = progress.bestTime {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Best Time")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.mutedSteelGray)
                                Text(formatTime(bestTime))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(AppColors.coldLightningCyan)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
        if minutes > 0 {
            return String(format: "%d:%02d.%d", minutes, seconds, milliseconds)
        }
        return String(format: "%d.%ds", seconds, milliseconds)
    }
}

struct LevelIndicator: View {
    let level: Int
    let isCompleted: Bool
    let isCurrent: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
                .frame(height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: isCurrent ? 2 : 0)
                )
            
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.deepStormBlueDark)
            } else {
                Text("\(level)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(textColor)
            }
        }
    }
    
    private var backgroundColor: Color {
        if isCompleted {
            return AppColors.electricGold
        }
        return AppColors.deepStormBlue.opacity(0.5)
    }
    
    private var borderColor: Color {
        isCurrent ? AppColors.coldLightningCyan : .clear
    }
    
    private var textColor: Color {
        isCurrent ? AppColors.coldLightningCyan : AppColors.mutedSteelGray
    }
}

#Preview {
    MainHubView(gameManager: GameManager.shared)
}

