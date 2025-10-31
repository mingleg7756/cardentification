//
//  PhotoRepo.swift
//  cardentification
//
//  Created by Anthony Jerez on 10/31/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseStorage

protocol PhotoRepository {
    func fetchPhotos(for userID: String) async throws -> [CarPhoto]
    func save(photo: CarPhoto, for userID: String) async throws
    func existsPhoto(withHash hash: String, for userID: String) async throws -> Bool
    func uploadImage(_ image: UIImage, userID: String) async throws -> String
    func deleteAll(for userID: String) async throws
}

final class FirestorePhotoRepository: PhotoRepository {
    func fetchPhotos(for userID: String) async throws -> [CarPhoto] {
        let snap = try await Firestore.firestore()
            .collection("users").document(userID)
            .collection("photos")
            .order(by: "selectedOn", descending: true)
            .getDocuments()
        return try snap.documents.map { try $0.data(as: CarPhoto.self) }
    }

    func save(photo: CarPhoto, for userID: String) async throws {
        let data = try Firestore.Encoder().encode(photo)
        try await Firestore.firestore()
            .collection("users").document(userID)
            .collection("photos").document(photo.id)
            .setData(data)
    }

    func existsPhoto(withHash hash: String, for userID: String) async throws -> Bool {
        let snap = try await Firestore.firestore()
            .collection("users").document(userID)
            .collection("photos")
            .whereField("hash", isEqualTo: hash)
            .getDocuments()
        return !snap.isEmpty
    }

    func uploadImage(_ image: UIImage, userID: String) async throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageError", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "Could not compress image"])
        }
        let ref = Storage.storage().reference()
            .child("users/\(userID)/photos/\(UUID().uuidString).jpg")

        // await putData
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            ref.putData(data, metadata: nil) { _, err in
                if let err = err { cont.resume(throwing: err) } else { cont.resume() }
            }
        }

        // await downloadURL
        let url: URL = try await withCheckedThrowingContinuation { cont in
            ref.downloadURL { url, err in
                if let err = err { cont.resume(throwing: err) }
                else { cont.resume(returning: url!) }
            }
        }
        return url.absoluteString
    }

    func deleteAll(for userID: String) async throws {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        let photosRef = db.collection("users").document(userID).collection("photos")
        let snap = try await photosRef.getDocuments()

        for doc in snap.documents {
            if let urlStr = doc.data()["imageURLString"] as? String,
               let url = URL(string: urlStr) {
                let path = url.path
                let decoded = path.components(separatedBy: "/o/").last?
                    .components(separatedBy: "?").first?
                    .removingPercentEncoding ?? ""
                try await storage.reference().child(decoded).delete()
            }
            try await doc.reference.delete()
        }
    }
}
