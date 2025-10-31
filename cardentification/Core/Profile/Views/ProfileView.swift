//
//  ProfileView.swift
//  cardentification
//
//  Created by Anthony Jerez on 4/18/25.

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var vm = ProfileViewModel()

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Profile")
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
                        VStack(spacing: 16) {
                            if let u = vm.user {
                                // user card
                                HStack(spacing: 14) {
                                    Text(u.initials)
                                        .font(.title2.bold())
                                        .foregroundColor(.white)
                                        .frame(width: 66, height: 66)
                                        .background(
                                            LinearGradient(colors: [Theme.red, Theme.redDark],
                                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                        .clipShape(Circle())

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(u.fullName).font(.headline)
                                        Text(u.email).font(.subheadline).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(16)
                                .background(Theme.glassCard)
                                .cornerRadius(20)
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.cardStroke, lineWidth: 1.1))
                                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                                .padding(.top, 16)
                                .padding(.horizontal, 16)

                                // general card
                                VStack(spacing: 0) {
                                    row(icon: "gear", title: "Version", trailing: "1.0.0")
                                }
                                .padding(12)
                                .background(Theme.glassCard)
                                .cornerRadius(20)
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.cardStroke, lineWidth: 1.1))
                                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                                .padding(.horizontal, 16)

                                // actions
                                VStack(spacing: 12) {
                                    Button { auth.signOut() } label: {
                                        Label("Sign out", systemImage: "arrow.left.circle.fill")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(OutlineRedButton())

                                    Button(role: .destructive) {
                                        Task { await auth.deleteAccount() }
                                    } label: {
                                        Label("Delete account", systemImage: "xmark.circle.fill")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(PrimaryRedButton())
                                    .disabled(vm.isBusy)
                                }
                                .padding(16)
                                .background(Theme.glassCard)
                                .cornerRadius(20)
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.cardStroke, lineWidth: 1.1))
                                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                                .padding(.horizontal, 16)
                            }

                            Spacer(minLength: 24)
                        }
                    }
                }
            }
        }
        .task {
            if let uid = auth.userSession?.uid { await vm.load(userID: uid) }
        }
    }

    private func row(icon: String, title: String, trailing: String? = nil) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).imageScale(.medium).font(.title3).foregroundColor(Theme.red)
            Text(title).font(.subheadline).foregroundColor(.black)
            Spacer()
            if let trailing = trailing {
                Text(trailing).font(.subheadline).foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 10)
    }
}

