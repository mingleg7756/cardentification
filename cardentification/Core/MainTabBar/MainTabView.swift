//
//  MainTabView.swift
//  cardentification
//
//  Created by Anthony Jerez on 4/18/25.
//

import SwiftUI

struct MainTabView: View {
    
    var body: some View {
        TabView {
            SnapCarPhotoView()
                .tabItem {
                    Label("Snap", systemImage: "camera")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}

#Preview {
    MainTabView().environmentObject(AuthViewModel())
}
