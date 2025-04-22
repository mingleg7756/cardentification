//
//  MainTabView.swift
//  cardentification
//
//  Created by Anthony Jerez on 4/18/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SnapCarPhotoView()
                .tabItem {
                    Label("Snap", systemImage: "camera")
                }
                .tag(0)
            
            CarListingsView()
                .tabItem {
                    Label("Listings", systemImage: "car.fill")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(2)
        }
    }
}

#Preview {
    MainTabView().environmentObject(AuthViewModel())
}
