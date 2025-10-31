//
//  ProfileViewModel.swift
//  cardentification
//
//  Created by Anthony Jerez on 10/31/25.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isBusy = false
    @Published var error: String?

    private let userRepo: UserRepository
    init(userRepo: UserRepository = FirestoreUserRepository()) { self.userRepo = userRepo }

    func load(userID: String) async {
        do { user = try await userRepo.fetchUser(userID: userID) }
        catch { self.error = error.localizedDescription }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            user = nil
        } catch {
            self.error = error.localizedDescription
        }
    }

    func deleteAccount(userID: String) async {
        isBusy = true
        defer { isBusy = false }
        do {
            try await userRepo.deleteAccount(userID: userID)
            user = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
}
