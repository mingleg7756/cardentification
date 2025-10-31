//
//  MainTabView.swift
//  cardentification
//
//  Created by Anthony Jerez on 4/18/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var vm = MainTabViewModel()

    var body: some View {
        TabView(selection: $vm.selected) {
            CarListingsView()
                .tag(MainTab.listings)
            
            SnapCarPhotoView()
                .tag(MainTab.snap)

            ProfileView()
                .tag(MainTab.profile)
        }
        .toolbar(.hidden, for: .tabBar)
        .tint(Theme.red)
        .safeAreaInset(edge: .bottom) {
            CustomTabBar(selected: $vm.selected)
        }
    }
}


