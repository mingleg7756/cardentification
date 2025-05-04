//
//  CarListingsView.swift
//  cardentification
//
//  Created by Anthony Jerez on 4/21/25.
//

import SwiftUI

struct CarListingsView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isLoading = true // track loading state
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Car Listings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top)

                if isLoading {
                    ProgressView("Loading car listings...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    if viewModel.currentPhotoCollection.isEmpty {
                        VStack(spacing: 8) {
                            Text("No car listings yet.")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Start taking photos of cars to get started!")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                    } else {
                        LazyVStack(spacing: 32) {
                            ForEach(viewModel.currentPhotoCollection) { photo in
                                ListingItemView(carPhoto: photo)
                                    .padding()
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchPhotoCollection()
                isLoading = false
            }
        }
    }
}

#Preview {
    CarListingsView().environmentObject(AuthViewModel())
}
