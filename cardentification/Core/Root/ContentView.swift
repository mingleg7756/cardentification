//  ContentView.swift
//  cardentification
//
//  Created by Tim Cook on 4/14/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        LandingPageView()
    }
}

#Preview {
    ContentView().environmentObject(AuthViewModel())
}
