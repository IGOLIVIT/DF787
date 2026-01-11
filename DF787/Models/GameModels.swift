//
//  GameModels.swift
//  DF787
//

import SwiftUI

// MARK: - Difficulty Levels
enum Difficulty: String, CaseIterable, Codable {
    case calm = "Calm"
    case focused = "Focused"
    case intense = "Intense"
    
    var color: Color {
        switch self {
        case .calm: return Color("ColdLightningCyan")
        case .focused: return Color("ElectricGold")
        case .intense: return Color("ElectricGold").opacity(0.8)
        }
    }
    
    var levels: Int {
        switch self {
        case .calm: return 10
        case .focused: return 15
        case .intense: return 20
        }
    }
    
    var speedMultiplier: Double {
        switch self {
        case .calm: return 1.0
        case .focused: return 0.75
        case .intense: return 0.5
        }
    }
}

// MARK: - Game Types
enum GameType: String, CaseIterable, Codable, Identifiable {
    case patternSurge = "Pattern Surge"
    case timingGate = "Timing Gate"
    case signalDivide = "Signal Divide"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .patternSurge: return "bolt.fill"
        case .timingGate: return "timer"
        case .signalDivide: return "arrow.triangle.branch"
        }
    }
    
    var description: String {
        switch self {
        case .patternSurge: return "Observe and reproduce the sequence"
        case .timingGate: return "Release pulses at the perfect moment"
        case .signalDivide: return "Sort signals into correct zones"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .patternSurge: return "Watch the illuminated symbols carefully, then recreate the exact sequence under time pressure. Patterns grow more complex as you advance."
        case .timingGate: return "Energy pulses flow through gates. Tap precisely when indicators align to channel the energy forward. Precision matters more than speed."
        case .signalDivide: return "Incoming signals must be sorted into the correct zones based on the rules shown before each level. Rules evolve as you progress."
        }
    }
}

// MARK: - Player Rank
enum PlayerRank: String, CaseIterable, Codable {
    case initiate = "Initiate"
    case apprentice = "Apprentice"
    case adept = "Adept"
    case keeper = "Keeper"
    case warden = "Warden"
    case master = "Master"
    case arcMaster = "Arc Master"
    case stormSovereign = "Storm Sovereign"
    
    var requiredLevels: Int {
        switch self {
        case .initiate: return 0
        case .apprentice: return 10
        case .adept: return 25
        case .keeper: return 50
        case .warden: return 80
        case .master: return 110
        case .arcMaster: return 135
        case .stormSovereign: return 135 // All 135 levels (3 games × 3 difficulties × 15 avg levels)
        }
    }
    
    var next: PlayerRank? {
        guard let index = PlayerRank.allCases.firstIndex(of: self),
              index + 1 < PlayerRank.allCases.count else { return nil }
        return PlayerRank.allCases[index + 1]
    }
}

// MARK: - Achievement
struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let icon: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    static let allAchievements: [Achievement] = [
        Achievement(id: "first_surge", title: "Storm Awakened", description: "Complete your first Pattern Surge level", icon: "bolt.circle.fill", isUnlocked: false),
        Achievement(id: "perfect_timing", title: "Precision Strike", description: "Achieve 100% accuracy in Timing Gate", icon: "scope", isUnlocked: false),
        Achievement(id: "signal_master", title: "Signal Conductor", description: "Complete 10 Signal Divide levels", icon: "waveform.path", isUnlocked: false),
        Achievement(id: "streak_5", title: "Momentum Builder", description: "Achieve a 5-level streak", icon: "flame.fill", isUnlocked: false),
        Achievement(id: "streak_10", title: "Unstoppable Force", description: "Achieve a 10-level streak", icon: "bolt.horizontal.fill", isUnlocked: false),
        Achievement(id: "all_calm", title: "Calm Navigator", description: "Complete all Calm difficulty levels", icon: "leaf.fill", isUnlocked: false),
        Achievement(id: "all_focused", title: "Focused Mind", description: "Complete all Focused difficulty levels", icon: "eye.fill", isUnlocked: false),
        Achievement(id: "all_intense", title: "Storm Conqueror", description: "Complete all Intense difficulty levels", icon: "hurricane", isUnlocked: false),
        Achievement(id: "first_rank", title: "Rising Power", description: "Reach Apprentice rank", icon: "arrow.up.circle.fill", isUnlocked: false),
        Achievement(id: "master_rank", title: "Arc Master", description: "Reach Arc Master rank", icon: "crown.fill", isUnlocked: false)
    ]
}

// MARK: - Game Progress
struct GameProgress: Codable {
    var gameType: GameType
    var difficulty: Difficulty
    var currentLevel: Int
    var completedLevels: [Int]
    var bestAccuracy: Double
    var bestTime: TimeInterval?
    
    var isComplete: Bool {
        completedLevels.count >= difficulty.levels
    }
    
    var progressPercentage: Double {
        Double(completedLevels.count) / Double(difficulty.levels)
    }
}

// MARK: - Player Stats
struct PlayerStats: Codable {
    var totalSessionsPlayed: Int
    var totalLevelsCompleted: Int
    var currentStreak: Int
    var bestStreak: Int
    var totalAccuracy: Double
    var accuracyCount: Int
    var lastPlayedDate: Date?
    
    var averageAccuracy: Double {
        guard accuracyCount > 0 else { return 0 }
        return totalAccuracy / Double(accuracyCount)
    }
    
    static var empty: PlayerStats {
        PlayerStats(
            totalSessionsPlayed: 0,
            totalLevelsCompleted: 0,
            currentStreak: 0,
            bestStreak: 0,
            totalAccuracy: 0,
            accuracyCount: 0,
            lastPlayedDate: nil
        )
    }
}

// MARK: - Level Result
struct LevelResult {
    let success: Bool
    let accuracy: Double
    let timeElapsed: TimeInterval
    let score: Int
}

