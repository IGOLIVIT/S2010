//
//  DesignSystem.swift
//  Dream Rhythm
//
//  Created by IGOR on 09/10/2025.
//

import SwiftUI

// MARK: - Colors
extension Color {
    static let dreamBackground = Color(hex: "FFF6E0")
    static let dreamPrimary = Color(hex: "F8B400")
    static let dreamAccent = Color(hex: "2C82C9")
    static let dreamSecondary = Color(hex: "E2E2E2")
    static let dreamNight = Color(hex: "1A1B3A")
    static let dreamSunrise = Color(hex: "FFE5B4")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography
struct DreamTypography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .rounded)
    static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
    static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
}

// MARK: - Button Styles
struct DreamPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DreamTypography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.dreamPrimary)
                    .shadow(color: Color.dreamPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct DreamSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DreamTypography.headline)
            .foregroundColor(.dreamAccent)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.dreamAccent, lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white.opacity(0.8))
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct DreamIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 44, height: 44)
            .background(
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Card Style
struct DreamCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
            )
    }
}

extension View {
    func dreamCard() -> some View {
        modifier(DreamCardStyle())
    }
}

// MARK: - Animations
struct DreamAnimations {
    static let gentle = Animation.easeInOut(duration: 0.6)
    static let bouncy = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let quick = Animation.easeInOut(duration: 0.3)
    static let slow = Animation.easeInOut(duration: 1.2)
}

// MARK: - Gradients
struct DreamGradients {
    static let dayNight = LinearGradient(
        colors: [Color.dreamNight, Color.dreamAccent, Color.dreamSunrise],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let sunrise = LinearGradient(
        colors: [Color.dreamSunrise, Color.dreamPrimary],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let peaceful = LinearGradient(
        colors: [Color.dreamBackground, Color.white],
        startPoint: .top,
        endPoint: .bottom
    )
}
