//
//  AuthViewModel.swift
//  cardentification
//
//  Created by Anthony Jerez on 4/18/25.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

protocol AuthenticationFormProtocol { var formIsValid: Bool { get } }

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?

    private var authListener: AuthStateDidChangeListenerHandle?
    private let userRepo: UserRepository

    init(userRepo: UserRepository = FirestoreUserRepository()) {
        self.userRepo = userRepo
        self.userSession = Auth.auth().currentUser

        // Listen to ALL auth changes
        self.authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            Task { @MainActor in
                self.userSession = user
                if let _ = user {
                    await self.fetchUser()
                } else {
                    self.currentUser = nil
                }
            }
        }

        Task { await fetchUser() }
    }

    deinit {
        if let h = authListener { Auth.auth().removeStateDidChangeListener(h) }
    }

    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            if let u = try await userRepo.fetchUser(userID: uid) {
                self.currentUser = u
            } else {
                signOut()
            }
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
        }
    }

    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("Failed to log in with error \(error.localizedDescription)")
        }
    }

    func createUser(withEmail email: String, password: String, fullName: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullName: fullName, email: email)
            try await userRepo.createOrUpdate(user)
            self.currentUser = user
        } catch {
            print("Failed to create user with error \(error.localizedDescription)")
        }
    }

    func signInWithGoogle() async {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.keyWindow?.rootViewController else { return }
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
            let gUser = result.user
            guard let idToken = gUser.idToken?.tokenString else { return }
            let accessToken = gUser.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            let authResult = try await Auth.auth().signIn(with: credential)

            self.userSession = authResult.user
            let profile = User(id: authResult.user.uid,
                               fullName: authResult.user.displayName ?? "No Name",
                               email: authResult.user.email ?? "No E-mail")
            try await userRepo.createOrUpdate(profile)
            self.currentUser = profile
        } catch {
            print("Google sign-in failed:", error.localizedDescription)
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
        } catch {
            print("Failed to sign out with error \(error.localizedDescription)")
        }
        self.userSession = nil
        self.currentUser = nil
    }

    // Delete account via repo
    func deleteAccount() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await userRepo.deleteAccount(userID: uid)
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("Failed to delete account: \(error.localizedDescription)")
        }
    }
}
