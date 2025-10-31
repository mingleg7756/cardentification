//
//  MainTabViewModel.swift
//  cardentification
//
//  Created by Anthony Jerez on 10/31/25.
//

import SwiftUI

@MainActor
final class MainTabViewModel: ObservableObject {
    @Published var selected: MainTab = .snap
}
