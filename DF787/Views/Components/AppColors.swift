//
//  AppColors.swift
//  DF787
//

import SwiftUI

struct AppColors {
    static let deepStormBlue = Color("DeepStormBlue")
    static let deepStormBlueDark = Color("DeepStormBlueDark")
    static let electricGold = Color("ElectricGold")
    static let coldLightningCyan = Color("ColdLightningCyan")
    static let softWhite = Color("SoftWhite")
    static let mutedSteelGray = Color("MutedSteelGray")
    
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [deepStormBlue, deepStormBlueDark],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [deepStormBlue.opacity(0.8), deepStormBlueDark.opacity(0.9)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var goldGradient: LinearGradient {
        LinearGradient(
            colors: [electricGold, electricGold.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var cyanGradient: LinearGradient {
        LinearGradient(
            colors: [coldLightningCyan, coldLightningCyan.opacity(0.6)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

