//
//  AchievementsView.swift
//  DF787
//

import SwiftUI

struct AchievementsView: View {
    @ObservedObject var gameManager: GameManager
    
    private var unlockedCount: Int {
        gameManager.achievements.filter { $0.isUnlocked }.count
    }
    
    var body: some View {
        ZStack {
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Achievements")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.softWhite)
                    
                    // Progress ring
                    ZStack {
                        ProgressRing(
                            progress: Double(unlockedCount) / Double(gameManager.achievements.count),
                            size: 100,
                            lineWidth: 8,
                            showPercentage: false
                        )
                        
                        VStack(spacing: 2) {
                            Text("\(unlockedCount)")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.electricGold)
                            
                            Text("of \(gameManager.achievements.count)")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.mutedSteelGray)
                        }
                    }
                }
                .padding(.top, 24)
                
                // Current rank
                GlassCard {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(AppColors.electricGold.opacity(0.2))
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: rankIcon)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(AppColors.electricGold)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Rank")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.mutedSteelGray)
                            
                            Text(gameManager.currentRank.rawValue)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.softWhite)
                        }
                        
                        Spacer()
                        
                        if let nextRank = gameManager.currentRank.next {
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Next")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.mutedSteelGray)
                                
                                Text(nextRank.rawValue)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppColors.coldLightningCyan)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Achievements list
                VStack(alignment: .leading, spacing: 16) {
                    Text("Titles & Seals")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.softWhite)
                        .padding(.horizontal, 20)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(gameManager.achievements) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 40)
                }
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
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        GlassCard(padding: 16) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(achievement.isUnlocked ? AppColors.electricGold.opacity(0.2) : AppColors.mutedSteelGray.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: achievement.icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(achievement.isUnlocked ? AppColors.electricGold : AppColors.mutedSteelGray.opacity(0.4))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(achievement.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(achievement.isUnlocked ? AppColors.softWhite : AppColors.mutedSteelGray)
                    
                    Text(achievement.description)
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.mutedSteelGray.opacity(achievement.isUnlocked ? 1 : 0.6))
                        .lineLimit(2)
                }
                
                Spacer()
                
                if achievement.isUnlocked {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.electricGold)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.mutedSteelGray.opacity(0.4))
                }
            }
        }
        .opacity(achievement.isUnlocked ? 1 : 0.7)
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        AchievementsView(gameManager: GameManager.shared)
    }
}

