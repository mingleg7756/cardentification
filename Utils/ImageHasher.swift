//
//  ImageHasher.swift
//  cardentification
//
//  Created by Anthony Jerez on 4/19/25.
//

import Foundation

import UIKit
import CryptoKit

struct ImageHasher {
    static func hashImage(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
}
