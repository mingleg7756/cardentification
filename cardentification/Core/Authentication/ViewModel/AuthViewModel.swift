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

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
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
            self.userSession = nil
            self.currentUser = nil
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
            
            print("Successfully deleted user and all associated data.")
        } catch {
            print("Failed to delete account: \(error.localizedDescription)")
        }
    }

    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
    }
    
    func savePhoto(imageURLString: String, make: String, model: String, probability: Double, years: String, hash: String) async {
        guard let uid = userSession?.uid else { return }
        let photo = CarPhoto(
            imageURLString: imageURLString,
            make: make,
            model: model,
            probability: probability,
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



}
