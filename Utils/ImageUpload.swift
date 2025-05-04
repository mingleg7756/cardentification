//
//  ImageUpload.swift
//  cardentification
//
//  Created by Anthony Jerez on 4/19/25.
//

import Foundation
import FirebaseStorage
import UIKit

func uploadImage(_ image: UIImage, forUserID uid: String, completion: @escaping (Result<String, Error>) -> Void) {
    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
        completion(.failure(NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not compress image."])))
        return
    }

    let filename = UUID().uuidString
    let ref = Storage.storage().reference().child("users/\(uid)/photos/\(filename).jpg")

    ref.putData(imageData, metadata: nil) { _, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        ref.downloadURL { url, error in
            if let error = error {
                completion(.failure(error))
            } else if let urlString = url?.absoluteString {
                completion(.success(urlString))
            }
        }
    }
}
