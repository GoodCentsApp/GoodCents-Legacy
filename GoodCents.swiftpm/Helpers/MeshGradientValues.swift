//
//  MeshGradientValues.swift
//  GoodCents
//
//  Created by GoodCents on 10/12/2024.
//

import Foundation
import SwiftUI

// a fluff ton of colors
enum MeshGradientValues {
    static let points: [SIMD2<Float>] = [
        [0, 0], [0.5, 0], [1.0, 0],
        [0, 0.5], [0.5, 0.5], [1.0, 0.5],
        [0, 1.0], [0.5, 1.0], [1.0, 1.0]
    ]
    
    static let progressTimeColors: [Color] = [
        Color(red: 1.0, green: 0.9, blue: 0.9),  // Soft pastel red
        Color(red: 1.0, green: 0.7, blue: 0.7),  // Light coral red
        Color(red: 1.0, green: 0.5, blue: 0.5),  // Warm rosy red
        Color(red: 0.9, green: 0.3, blue: 0.3),  // Bright strawberry red
        Color(red: 0.8, green: 0.1, blue: 0.1),  // Rich cherry red
        Color(red: 0.7, green: 0.0, blue: 0.0),  // Deep crimson red
        Color(red: 1.0, green: 0.6, blue: 0.6),  // Salmon pink-red
        Color(red: 0.9, green: 0.4, blue: 0.4),  // Vibrant ruby red
        .pink
    ]
    
    static let quizColors: [Color] = [
        Color(red: 0.9, green: 0.9, blue: 1.0),  // Soft pastel blue
        Color(red: 0.7, green: 0.7, blue: 1.0),  // Light periwinkle blue
        Color(red: 0.5, green: 0.5, blue: 1.0),  // Bright sky blue
        Color(red: 0.3, green: 0.3, blue: 0.9),  // Vibrant sapphire blue
        Color(red: 0.1, green: 0.1, blue: 0.8),  // Rich cobalt blue
        Color(red: 0.0, green: 0.0, blue: 0.7),  // Deep navy blue
        Color(red: 0.4, green: 0.6, blue: 1.0),  // Ocean blue
        Color(red: 0.3, green: 0.5, blue: 0.9),  // Electric cerulean blue
        .blue                                    // Default blue color
    ]
    
    static let lessonPassColors: [Color] = [
        Color(red: 0.9, green: 1.0, blue: 0.9),  // Soft pastel green
        Color(red: 0.7, green: 1.0, blue: 0.7),  // Light mint green
        Color(red: 0.5, green: 1.0, blue: 0.5),  // Vibrant lime green
        Color(red: 0.3, green: 0.9, blue: 0.3),  // Bright apple green
        Color(red: 0.2, green: 0.8, blue: 0.2),  // Rich leafy green
        Color(red: 0.6, green: 1.0, blue: 0.6),  // Soft jade green
        Color(red: 0.4, green: 0.9, blue: 0.4),  // Fresh grass green
        Color(red: 0.3, green: 0.8, blue: 0.3),  // Electric emerald green
        .green                                   // Default green color
    ]
    
    static let lessonHalfPassColors: [Color] = [
        Color(red: 1.0, green: 1.0, blue: 0.8),  // Soft pastel yellow
        Color(red: 1.0, green: 0.9, blue: 0.6),  // Light butter yellow
        Color(red: 1.0, green: 0.8, blue: 0.4),  // Vibrant sunflower yellow
        Color(red: 1.0, green: 0.7, blue: 0.2),  // Bright golden yellow
        Color(red: 0.9, green: 0.6, blue: 0.1),  // Rich amber yellow
        Color(red: 1.0, green: 0.9, blue: 0.5),  // Soft honey yellow
        Color(red: 1.0, green: 0.8, blue: 0.3),  // Warm marigold yellow
        Color(red: 0.9, green: 0.7, blue: 0.2),  // Deep saffron yellow
        .yellow                                  // Default yellow color
    ]
    
    static let lessonFailColors: [Color] = [
        Color(red: 1.0, green: 0.7, blue: 0.7),  // Light coral red
        Color(red: 0.9, green: 0.4, blue: 0.4),  // Vibrant ruby red
        Color(red: 0.8, green: 0.2, blue: 0.2),  // Bold cherry red
        Color(red: 0.7, green: 0.1, blue: 0.1),  // Deep crimson red
        Color(red: 0.6, green: 0.0, blue: 0.0),  // Dark blood red
        Color(red: 0.5, green: 0.0, blue: 0.0),  // Rich wine red
        Color(red: 0.8, green: 0.3, blue: 0.3),  // Warm brick red
        Color(red: 0.7, green: 0.2, blue: 0.2),  // Intense garnet red
        Color(red: 0.6, green: 0.1, blue: 0.1),  // Dark ruby red
        .red                                     // Default red color
    ]
    
    static let interactiveEventColors: [Color] = [
        Color(red: 1.0, green: 0.8, blue: 1.0),  // Light lavender pink
        Color(red: 1.0, green: 0.6, blue: 1.0),  // Warm fuchsia
        Color(red: 0.9, green: 0.4, blue: 0.9),  // Bright magenta
        Color(red: 0.8, green: 0.2, blue: 0.8),  // Electric orchid
        Color(red: 0.7, green: 0.1, blue: 0.7),  // Deep neon plum
        Color(red: 0.6, green: 0.0, blue: 0.6),  // Dark purple-pink
        Color(red: 1.0, green: 0.7, blue: 0.9),  // Bubblegum pink
        Color(red: 0.9, green: 0.3, blue: 0.7),  // Hot pink
        Color(red: 0.8, green: 0.2, blue: 0.6),  // Raspberry pink
        .pink,  // Default pink color
        .purple // Default purple color
    ]
    
    static let moneyThemeColors: [Color] = [
        Color(red: 0.8, green: 0.95, blue: 1.0),  // Light sky blue
        Color(red: 0.6, green: 0.85, blue: 1.0),  // Soft cerulean
        Color(red: 0.4, green: 0.75, blue: 0.9),  // Cool aqua blue
        Color(red: 0.2, green: 0.6, blue: 0.8),   // Ocean blue
        Color(red: 0.1, green: 0.5, blue: 0.7),   // Deep teal blue
        Color(red: 0.0, green: 0.4, blue: 0.6),   // Dark navy teal
        Color(red: 0.7, green: 0.9, blue: 0.8),   // Mint green
        Color(red: 0.3, green: 0.8, blue: 0.7),   // Turquoise
        Color(red: 0.2, green: 0.7, blue: 0.6),   // Seafoam green
        .cyan,                                    // Default cyan color
        .teal                                     // Default teal color
    ]
    
// MARK: - function that returns inputted colors and returns it shuffled
    static func randomColors(from colors: [Color]) -> [Color] {
        colors.shuffled()
    }
}
