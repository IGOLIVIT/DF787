//
//  StatisticsView.swift
//  DF787
//

import SwiftUI

struct StatisticsView: View {
    @ObservedObject var gameManager: GameManager
    @State private var showingResetConfirmation = false
    
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Statistics")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.softWhite)
                    
                    Text("Your journey at a glance")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.mutedSteelGray)
                }
                .padding(.top, 24)
                
                // Main stats card
                GlassCard {
                    VStack(spacing: 20) {
                        StatItem(
                            title: "Total Sessions",
                            value: "\(gameManager.playerStats.totalSessionsPlayed)",
                            icon: "play.circle.fill"
                        )
                        
                        Divider()
                            .background(AppColors.mutedSteelGray.opacity(0.3))
                        
                        StatItem(
                            title: "Levels Completed",
                            value: "\(gameManager.playerStats.totalLevelsCompleted)",
                            icon: "checkmark.circle.fill"
                        )
                        
                        Divider()
                            .background(AppColors.mutedSteelGray.opacity(0.3))
                        
                        StatItem(
                            title: "Best Streak",
                            value: "\(gameManager.playerStats.bestStreak)",
                            icon: "flame.fill"
                        )
                        
                        Divider()
                            .background(AppColors.mutedSteelGray.opacity(0.3))
                        
                        StatItem(
                            title: "Average Accuracy",
                            value: "\(Int(gameManager.playerStats.averageAccuracy * 100))%",
                            icon: "scope"
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                // Current streak
                if gameManager.playerStats.currentStreak > 0 {
                    GlassCard {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.electricGold.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(AppColors.electricGold)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current Streak")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.mutedSteelGray)
                                
                                Text("\(gameManager.playerStats.currentStreak) levels")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(AppColors.electricGold)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Game-specific stats
                VStack(alignment: .leading, spacing: 16) {
                    Text("By Challenge")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.softWhite)
                        .padding(.horizontal, 20)
                    
                    ForEach(GameType.allCases) { gameType in
                        GameStatCard(gameType: gameType, gameManager: gameManager)
                    }
                }
                
                // Reset progress
                VStack(spacing: 16) {
                    Divider()
                        .background(AppColors.mutedSteelGray.opacity(0.3))
                        .padding(.horizontal, 20)
                    
                    Button {
                        showingResetConfirmation = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 16, weight: .medium))
                            
                            Text("Reset Progress")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(Color.red.opacity(0.8))
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.red.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 40)
                }
            }
        }
        .alert("Reset All Progress?", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                gameManager.resetAllProgress()
            }
        } message: {
            Text("This will erase all your progress, achievements, and statistics. This action cannot be undone.")
        }
    }
}

struct GameStatCard: View {
    let gameType: GameType
    @ObservedObject var gameManager: GameManager
    
    private var totalCompleted: Int {
        Difficulty.allCases.reduce(0) { count, difficulty in
            count + gameManager.getProgress(for: gameType, difficulty: difficulty).completedLevels.count
        }
    }
    
    private var totalLevels: Int {
        Difficulty.allCases.reduce(0) { $0 + $1.levels }
    }
    
    private var bestAccuracy: Double {
        Difficulty.allCases.map { difficulty in
            gameManager.getProgress(for: gameType, difficulty: difficulty).bestAccuracy
        }.max() ?? 0
    }
    
    var body: some View {
        GlassCard(padding: 16) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.electricGold.opacity(0.15))
                        .frame(width: 46, height: 46)
                    
                    Image(systemName: gameType.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(AppColors.electricGold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(gameType.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.softWhite)
                    
                    Text("\(totalCompleted)/\(totalLevels) levels")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.mutedSteelGray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Best")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.mutedSteelGray)
                    
                    Text("\(Int(bestAccuracy * 100))%")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.coldLightningCyan)
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        StatisticsView(gameManager: GameManager.shared)
    }
}

