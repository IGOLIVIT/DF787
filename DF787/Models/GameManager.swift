//
//  GameManager.swift
//  DF787
//

import SwiftUI
import Combine

class GameManager: ObservableObject {
    static let shared = GameManager()
    
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    @Published var playerStats: PlayerStats {
        didSet {
            savePlayerStats()
        }
    }
    
    @Published var gameProgress: [String: GameProgress] {
        didSet {
            saveGameProgress()
        }
    }
    
    @Published var achievements: [Achievement] {
        didSet {
            saveAchievements()
        }
    }
    
    @Published var currentRank: PlayerRank = .initiate
    
    private init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self.playerStats = PlayerStats.empty
        self.gameProgress = [:]
        self.achievements = Achievement.allAchievements
        
        loadPlayerStats()
        loadGameProgress()
        loadAchievements()
        updateRank()
    }
    
    // MARK: - Progress Key Generation
    private func progressKey(for gameType: GameType, difficulty: Difficulty) -> String {
        "\(gameType.rawValue)_\(difficulty.rawValue)"
    }
    
    // MARK: - Get Progress
    func getProgress(for gameType: GameType, difficulty: Difficulty) -> GameProgress {
        let key = progressKey(for: gameType, difficulty: difficulty)
        if let progress = gameProgress[key] {
            return progress
        }
        let newProgress = GameProgress(
            gameType: gameType,
            difficulty: difficulty,
            currentLevel: 1,
            completedLevels: [],
            bestAccuracy: 0,
            bestTime: nil
        )
        gameProgress[key] = newProgress
        return newProgress
    }
    
    // MARK: - Update Progress
    func updateProgress(for gameType: GameType, difficulty: Difficulty, level: Int, result: LevelResult) {
        let key = progressKey(for: gameType, difficulty: difficulty)
        var progress = getProgress(for: gameType, difficulty: difficulty)
        
        if result.success && !progress.completedLevels.contains(level) {
            progress.completedLevels.append(level)
            progress.currentLevel = min(level + 1, difficulty.levels)
            
            // Update player stats
            playerStats.totalLevelsCompleted += 1
            playerStats.currentStreak += 1
            if playerStats.currentStreak > playerStats.bestStreak {
                playerStats.bestStreak = playerStats.currentStreak
            }
            
            // Check achievements
            checkAchievements(gameType: gameType, difficulty: difficulty, result: result)
        } else if !result.success {
            playerStats.currentStreak = 0
        }
        
        // Update accuracy
        if result.accuracy > progress.bestAccuracy {
            progress.bestAccuracy = result.accuracy
        }
        playerStats.totalAccuracy += result.accuracy
        playerStats.accuracyCount += 1
        
        // Update time
        if let bestTime = progress.bestTime {
            if result.timeElapsed < bestTime {
                progress.bestTime = result.timeElapsed
            }
        } else {
            progress.bestTime = result.timeElapsed
        }
        
        gameProgress[key] = progress
        updateRank()
    }
    
    // MARK: - Session Tracking
    func recordSession() {
        playerStats.totalSessionsPlayed += 1
        playerStats.lastPlayedDate = Date()
    }
    
    // MARK: - Rank Management
    private func updateRank() {
        let totalCompleted = playerStats.totalLevelsCompleted
        var newRank: PlayerRank = .initiate
        
        for rank in PlayerRank.allCases.reversed() {
            if totalCompleted >= rank.requiredLevels {
                newRank = rank
                break
            }
        }
        
        if newRank != currentRank {
            currentRank = newRank
            
            // Unlock rank achievements
            if newRank == .apprentice {
                unlockAchievement(id: "first_rank")
            } else if newRank == .arcMaster {
                unlockAchievement(id: "master_rank")
            }
        }
    }
    
    // MARK: - Achievement Management
    private func checkAchievements(gameType: GameType, difficulty: Difficulty, result: LevelResult) {
        // First surge
        if gameType == .patternSurge && !isAchievementUnlocked(id: "first_surge") {
            unlockAchievement(id: "first_surge")
        }
        
        // Perfect timing
        if gameType == .timingGate && result.accuracy >= 1.0 && !isAchievementUnlocked(id: "perfect_timing") {
            unlockAchievement(id: "perfect_timing")
        }
        
        // Signal master
        let signalProgress = getAllProgress(for: .signalDivide)
        let totalSignalCompleted = signalProgress.reduce(0) { $0 + $1.completedLevels.count }
        if totalSignalCompleted >= 10 && !isAchievementUnlocked(id: "signal_master") {
            unlockAchievement(id: "signal_master")
        }
        
        // Streak achievements
        if playerStats.currentStreak >= 5 && !isAchievementUnlocked(id: "streak_5") {
            unlockAchievement(id: "streak_5")
        }
        if playerStats.currentStreak >= 10 && !isAchievementUnlocked(id: "streak_10") {
            unlockAchievement(id: "streak_10")
        }
        
        // Difficulty completion achievements
        checkDifficultyCompletion()
    }
    
    private func checkDifficultyCompletion() {
        // Check Calm completion
        let allCalmComplete = GameType.allCases.allSatisfy { gameType in
            getProgress(for: gameType, difficulty: .calm).isComplete
        }
        if allCalmComplete && !isAchievementUnlocked(id: "all_calm") {
            unlockAchievement(id: "all_calm")
        }
        
        // Check Focused completion
        let allFocusedComplete = GameType.allCases.allSatisfy { gameType in
            getProgress(for: gameType, difficulty: .focused).isComplete
        }
        if allFocusedComplete && !isAchievementUnlocked(id: "all_focused") {
            unlockAchievement(id: "all_focused")
        }
        
        // Check Intense completion
        let allIntenseComplete = GameType.allCases.allSatisfy { gameType in
            getProgress(for: gameType, difficulty: .intense).isComplete
        }
        if allIntenseComplete && !isAchievementUnlocked(id: "all_intense") {
            unlockAchievement(id: "all_intense")
        }
    }
    
    private func getAllProgress(for gameType: GameType) -> [GameProgress] {
        Difficulty.allCases.map { getProgress(for: gameType, difficulty: $0) }
    }
    
    func isAchievementUnlocked(id: String) -> Bool {
        achievements.first { $0.id == id }?.isUnlocked ?? false
    }
    
    func unlockAchievement(id: String) {
        if let index = achievements.firstIndex(where: { $0.id == id }) {
            achievements[index].isUnlocked = true
            achievements[index].unlockedDate = Date()
        }
    }
    
    // MARK: - Overall Progress
    func overallProgress() -> Double {
        var totalLevels = 0
        var completedLevels = 0
        
        for gameType in GameType.allCases {
            for difficulty in Difficulty.allCases {
                totalLevels += difficulty.levels
                completedLevels += getProgress(for: gameType, difficulty: difficulty).completedLevels.count
            }
        }
        
        guard totalLevels > 0 else { return 0 }
        return Double(completedLevels) / Double(totalLevels)
    }
    
    func gameOverallProgress(for gameType: GameType) -> Double {
        var totalLevels = 0
        var completedLevels = 0
        
        for difficulty in Difficulty.allCases {
            totalLevels += difficulty.levels
            completedLevels += getProgress(for: gameType, difficulty: difficulty).completedLevels.count
        }
        
        guard totalLevels > 0 else { return 0 }
        return Double(completedLevels) / Double(totalLevels)
    }
    
    // MARK: - Reset Progress
    func resetAllProgress() {
        playerStats = PlayerStats.empty
        gameProgress = [:]
        achievements = Achievement.allAchievements
        currentRank = .initiate
        
        UserDefaults.standard.removeObject(forKey: "playerStats")
        UserDefaults.standard.removeObject(forKey: "gameProgress")
        UserDefaults.standard.removeObject(forKey: "achievements")
    }
    
    // MARK: - Persistence
    private func savePlayerStats() {
        if let encoded = try? JSONEncoder().encode(playerStats) {
            UserDefaults.standard.set(encoded, forKey: "playerStats")
        }
    }
    
    private func loadPlayerStats() {
        if let data = UserDefaults.standard.data(forKey: "playerStats"),
           let decoded = try? JSONDecoder().decode(PlayerStats.self, from: data) {
            playerStats = decoded
        }
    }
    
    private func saveGameProgress() {
        if let encoded = try? JSONEncoder().encode(gameProgress) {
            UserDefaults.standard.set(encoded, forKey: "gameProgress")
        }
    }
    
    private func loadGameProgress() {
        if let data = UserDefaults.standard.data(forKey: "gameProgress"),
           let decoded = try? JSONDecoder().decode([String: GameProgress].self, from: data) {
            gameProgress = decoded
        }
    }
    
    private func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: "achievements")
        }
    }
    
    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: "achievements"),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            // Merge with default achievements to include any new ones
            var mergedAchievements = Achievement.allAchievements
            for saved in decoded {
                if let index = mergedAchievements.firstIndex(where: { $0.id == saved.id }) {
                    mergedAchievements[index] = saved
                }
            }
            achievements = mergedAchievements
        }
    }
}

