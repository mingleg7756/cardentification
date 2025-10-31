//
//  UserRepo.swift
//  cardentification
//
//  Created by Anthony Jerez on 10/31/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol UserRepository {
    func fetchUser(userID: String) async throws -> User?
    func createOrUpdate(_ user: User) async throws
    func deleteAccount(userID: String) async throws
}

final class FirestoreUserRepository: UserRepository {
    private let photoRepo: PhotoRepository
    init(photoRepo: PhotoRepository = FirestorePhotoRepository()) { self.photoRepo = photoRepo }

    func fetchUser(userID: String) async throws -> User? {
        let doc = try await Firestore.firestore().collection("users").document(userID).getDocument()
        guard doc.exists else { return nil }
        return try doc.data(as: User.self)
    }

    func createOrUpdate(_ user: User) async throws {
        let data = try Firestore.Encoder().encode(user)
        try await Firestore.firestore()
            .collection("users").document(user.id)
            .setData(data, merge: true)
    }

    func deleteAccount(userID: String) async throws {
        try await photoRepo.deleteAll(for: userID)
        try await Firestore.firestore().collection("users").document(userID).delete()
        if let current = Auth.auth().currentUser, current.uid == userID {
            try await current.delete()
        }
    }
}

