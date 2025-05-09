//
//  AuthViewModel.swift
//  cardentification
//
//  Created by Anthony Jerez on 4/18/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import GoogleSignIn
import FirebaseCore

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var currentPhotoCollection: [CarPhoto] = []
    
    init() {
        self.userSession = Auth.auth().currentUser
        Task {
            await fetchUser()
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
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        } catch {
            print("Failed to create user with error \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            signOutGoogle()
            self.userSession = nil
            self.currentUser = nil
            self.currentPhotoCollection = []
        } catch {
            print("Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() async {
        guard let user = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        let storage = Storage.storage()
        let userDocRef = db.collection("users").document(user.uid)
        let photosCollectionRef = userDocRef.collection("photos")
        
        do {
            let snapshot = try await photosCollectionRef.getDocuments()
            for document in snapshot.documents {
                if let imageURLString = document.data()["imageURLString"] as? String,
                   let url = URL(string: imageURLString) {
                    let path = url.path
                    let decodedPath = path
                        .components(separatedBy: "/o/")
                        .last?
                        .components(separatedBy: "?")
                        .first?
                        .removingPercentEncoding ?? ""
                    
                    let storageRef = storage.reference().child(decodedPath)
                    try await storageRef.delete()
                }
                try await document.reference.delete()
            }
            try await userDocRef.delete()
            try await user.delete()
            self.userSession = nil
            self.currentUser = nil
            self.currentPhotoCollection = []
            
            print("Successfully deleted user and all associated data.")
        } catch {
            print("Failed to delete account: \(error.localizedDescription)")
        }
    }

    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userDoc = Firestore.firestore().collection("users").document(uid)
        
        do {
            let snapshot = try await userDoc.getDocument()
            
            if !snapshot.exists {
                await MainActor.run {
                    self.signOut()
                }
                return
            }
            
            self.currentUser = try snapshot.data(as: User.self)
            
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
        }
    }


    
    func savePhoto(imageURLString: String, make: String, model: String, probability: Double, generation: String, years: String, hash: String) async {
        guard let uid = userSession?.uid else { return }
        let photo = CarPhoto(
            imageURLString: imageURLString,
            make: make,
            model: model,
            probability: probability,
            generation: generation,
            years: years,
            selectedOn: Date(),
            hash: hash
        )

        do {
            let encodedPhoto = try Firestore.Encoder().encode(photo)
            try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .collection("photos")
                .document(photo.id)
                .setData(encodedPhoto)
        } catch {
            print("Failed to save photo with error: \(error.localizedDescription)")
        }
    }
    
    func checkForDuplicatePhotoHash(_ hash: String) async -> Bool {
        guard let uid = userSession?.uid else {
            return false
        }
        do {
            let snapshot = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .collection("photos")
                .whereField("hash", isEqualTo: hash)
                .getDocuments()

            return !snapshot.isEmpty
        } catch {
            print("Error checking for duplicate hash: \(error.localizedDescription)")
            return false
        }
    }
    
    func fetchPhotoCollection() async {
        guard let uid = userSession?.uid else { return }
        do {
            let snapshot = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .collection("photos")
                .order(by: "selectedOn", descending: true)
                .getDocuments()
            
            self.currentPhotoCollection = try snapshot.documents.compactMap {
                try $0.data(as: CarPhoto.self)
            }
        } catch {
            print("Failed to fetch photo collection: \(error.localizedDescription)")
        }
    }

}

extension AuthViewModel {
    // Google sign-in
    func signInWithGoogle() async {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.keyWindow?.rootViewController else { return }
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
            let user   = result.user
            guard let idToken = user.idToken?.tokenString else { return }
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            let authResult = try await Auth.auth().signIn(with: credential)
            self.userSession = authResult.user
            if authResult.additionalUserInfo?.isNewUser == true {
                let newUser = User(id: authResult.user.uid,
                                   fullName: authResult.user.displayName ?? "No Name",
                                   email: authResult.user.email ?? "No E-mail")
                let encoded = try Firestore.Encoder().encode(newUser)
                try await Firestore.firestore()
                     .collection("users")
                     .document(newUser.id)
                     .setData(encoded)
            }
            await fetchUser()
        } catch {
            print("Google sign-in failed:", error.localizedDescription)
        }
    }

    // Google sign out
    func signOutGoogle() {
        GIDSignIn.sharedInstance.signOut()
    }
}
