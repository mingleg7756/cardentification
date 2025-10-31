//
//  CustomTabBar.swift
//  cardentification
//
//  Created by Anthony Jerez on 10/31/25.
//

import SwiftUI
import UIKit

enum MainTab: Int, Hashable {
    case snap = 0
    case listings = 1
    case profile = 2
}

struct CustomTabBar: View {
    @Binding var selected: MainTab

    var body: some View {
        HStack(alignment: .center) {
            tabItem(.listings, title: "Listings", system: "car.fill")

            Spacer(minLength: 32)

            centerSnapButton()

            Spacer(minLength: 32)

            tabItem(.profile, title: "Profile", system: "person.circle")
        }
        .padding(.horizontal, 18)
        .padding(.top, 15)
        .padding(.bottom, 10)
        .background(Theme.glassCard)
        .cornerRadius(36)
        .overlay(
            RoundedRectangle(cornerRadius: 36)
                .stroke(Theme.cardStroke, lineWidth: 1.1)
        )
        .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 6)
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private func tabItem(_ tab: MainTab, title: String, system: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                selected = tab
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: system)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.caption2.weight(.semibold))
            }
            .frame(minWidth: 64)
            .padding(.vertical, 6)
            .foregroundStyle(selected == tab ? Theme.red : Color.secondary)
            .background(
                Group {
                    if selected == tab {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Theme.red.opacity(0.10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Theme.red.opacity(0.25), lineWidth: 1)
                            )
                            .padding(.horizontal, 4)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
        .accessibilityAddTraits(selected == tab ? [.isSelected] : [])
    }

    @ViewBuilder
    private func centerSnapButton() -> some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                selected = .snap
            }
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [Theme.red, Theme.redDark],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 64, height: 64)
                    .shadow(color: Theme.red.opacity(0.35), radius: 12, x: 0, y: 6)

                Image(systemName: "camera.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 22, weight: .bold))
            }
            .accessibilityLabel("Snap")
            .accessibilityHint("Open camera to identify a car")
        }
        .buttonStyle(.plain)
        .offset(y: -12)
        .contextMenu {
            Button("Take Photo", systemImage: "camera") { selected = .snap }
            Button("Choose from Library", systemImage: "photo") { selected = .snap }
        }
    }
}
