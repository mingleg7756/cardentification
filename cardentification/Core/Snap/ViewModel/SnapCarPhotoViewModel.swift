//
//  SnapCarPhotoViewModel.swift
//  cardentification
//
//  Created by Anthony Jerez on 10/31/25.
//

import SwiftUI

@MainActor
final class SnapCarPhotoViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var isIdentifying = false
    @Published var showPicker = false
    @Published var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    @Published var toast: String?

    private let carIdentifier: CarIdentifier
    private let photoRepo: PhotoRepository

    init(carIdentifier: CarIdentifier = CarNetIdentifier(),
         photoRepo: PhotoRepository = FirestorePhotoRepository()) {
        self.carIdentifier = carIdentifier
        self.photoRepo = photoRepo
    }

    func choose(_ source: UIImagePickerController.SourceType) {
        pickerSource = source
        showPicker = true
    }

    func identifyAndSave(for userID: String) async {
        guard let img = image else { return }
        isIdentifying = true
        defer { isIdentifying = false }

        do {
            // prevent duplicates
            guard let hash = ImageHasher.hashImage(img) else { throw NSError(domain: "hash", code: 0) }
            if try await photoRepo.existsPhoto(withHash: hash, for: userID) {
                toast = "Duplicate photo detected"
                return
            }

            // identify
            let match = try await carIdentifier.identify(from: img)
            // upload
            let url = try await photoRepo.uploadImage(img, userID: userID)
            // save
            let photo = CarPhoto(
                id: UUID().uuidString,
                imageURLString: url,
                make: match.make, model: match.model,
                probability: match.probability,
                generation: match.generation, years: match.years,
                selectedOn: Date(), hash: hash
            )
            try await photoRepo.save(photo: photo, for: userID)
            toast = "Saved \(match.make) \(match.model)"
        } catch {
            toast = error.localizedDescription
        }
    }
}
