//
//  CarListingsView.swift
//  cardentification
//
//  Created by Anthony Jerez on 4/21/25.
//

import SwiftUI

struct CarListingsView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var vm = CarListingsViewModel()

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Car Listings")
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 1)
                    Spacer()
                }
                .padding(.top, 8)
                .padding(.horizontal, 20)

                ZStack {
                    Color.white
                        .clipShape(RoundedCorner(radius: 28, corners: [.topLeft, .topRight]))
                        .ignoresSafeArea(edges: .bottom)
                        .overlay(
                            RoundedCorner(radius: 28, corners: [.topLeft, .topRight])
                                .stroke(Theme.cardStroke, lineWidth: 1.2)
                                .ignoresSafeArea(edges: .bottom)
                        )

                    ScrollView {
                        LazyVStack(spacing: 20) {
                            if !vm.isLoading && vm.photos.isEmpty {
                                emptyState.padding(.top, 40)
                            } else {
                                ForEach(vm.photos) { photo in
                                    ListingItemView(carPhoto: photo)
                                        .padding(.horizontal, 16)
                                }
                                .padding(.top, 16)
                                .padding(.bottom, 24)
                            }
                        }
                    }
                }
            }
        }
        .task {
            if let uid = auth.userSession?.uid { await vm.load(for: uid) }
        }
        .overlay {
            if vm.isLoading {
                ProgressView("Loading car listings…")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "car.fill").font(.system(size: 40)).foregroundColor(Theme.red)
            Text("No car listings yet").font(.headline)
            Text("Snap a photo to get started!").font(.subheadline).foregroundColor(.secondary)
        }
        .padding(20)
        .background(Theme.glassCard)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.cardStroke, lineWidth: 1.1))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}
