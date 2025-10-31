//
//  Theme.swift
//  cardentification
//
//  Created by Anthony Jerez on 10/31/25.
//

import Foundation
import SwiftUI
import UIKit

enum Theme {
    // App theme colors
    static let red      = Color(red: 0.929, green: 0.067, blue: 0.012)
    static let redDark  = Color(red: 0.45,  green: 0.00,  blue: 0.00)

    static let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Theme.red, .black]),
        startPoint: .top, endPoint: .bottom
    )

    // Card used on login/signup
    static let glassCard = Color.white.opacity(0.88)
    static let cardStroke = Theme.red.opacity(0.95)
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 24
    var corners: UIRectCorner = [.topLeft, .topRight]
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// Red primary button style
struct PrimaryRedButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                LinearGradient(colors: [Theme.red, Theme.redDark],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: Theme.red.opacity(0.35),
                    radius: configuration.isPressed ? 2 : 6, x: 0, y: 3)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct OutlineRedButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white)
            .foregroundColor(Theme.red)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.red, lineWidth: 1.2)
            )
            .cornerRadius(12)
            .shadow(color: .black.opacity(configuration.isPressed ? 0.05 : 0.08),
                    radius: configuration.isPressed ? 2 : 5, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

