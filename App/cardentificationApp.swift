//
//  cardentificationApp.swift
//  cardentification
//
//  Created by Tim Cook on 4/14/25.
//

import SwiftUI
import Firebase

@main
struct cardentificationApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(viewModel)
        }
    }
}
