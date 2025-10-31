//
//  CarListingsViewModel.swift
//  cardentification
//
//  Created by Anthony Jerez on 10/31/25.
//

import SwiftUI

@MainActor
final class CarListingsViewModel: ObservableObject {
    @Published var photos: [CarPhoto] = []
    @Published var isLoading = false
    @Published var error: String?

    private let repo: PhotoRepository
    init(repo: PhotoRepository = FirestorePhotoRepository()) { self.repo = repo }

    func load(for userID: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            self.photos = try await repo.fetchPhotos(for: userID)
        } catch {
            self.error = error.localizedDescription
        }
    }
}
