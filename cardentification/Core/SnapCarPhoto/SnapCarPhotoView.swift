
//
//  SnapCarPhotoView.swift
//  cardentification
//
//  Created by Anthony Jerez on 4/18/25.
//

import SwiftUI
import UIKit
import FirebaseFirestore

struct SnapCarPhotoView: View {
    @State private var showImagePicker = false
    @State private var selectedSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showSourceSelection = false
    @State private var image: UIImage?
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        if viewModel.currentUser != nil {
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                } else {
                    Text("No photo yet!")
                        .foregroundColor(.gray)
                }
                
                Button("Select a photo") {
                    showSourceSelection = true
                }
                .font(.title2)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Identify Car") {
                    guard let image = image, let user = viewModel.currentUser else { return }

                    CarNetAPI.identifyCar(image: image) { result in
                        DispatchQueue.main.async {
                            if result.starts(with: "Error") || result.starts(with: "Request error") || result.starts(with: "HTTP Error") || result.starts(with: "JSON error") {
                                print("Car identification failed: \(result)")
                            } else {
                                let details = result.split(separator: ",")
                                if details.count == 5 {
                                    let make = String(details[0])
                                    let model = String(details[1])
                                    let generation = String(details[2])
                                    let years = String(details[3])
                                    let probability = Double(details[4]) ?? 0.0
                                    if let hash = ImageHasher.hashImage(image) {
                                        Task {
                                            let isDuplicate = await viewModel.checkForDuplicatePhotoHash(hash)
                                            if isDuplicate {
                                                print("Duplicate image detected, not saving.")
                                            } else {
                                                uploadImage(image, forUserID: user.id) { uploadResult in
                                                    switch uploadResult {
                                                    case .success(let imageURL):
                                                        Task {
                                                            await viewModel.savePhoto(
                                                                imageURLString: imageURL,
                                                                make: make,
                                                                model: model,
                                                                probability: probability,
                                                                generation: generation,
                                                                years: years,
                                                                hash: hash
                                                            )
                                                        }
                                                    case .failure(let error):
                                                        print("Image upload failed: \(error.localizedDescription)")
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        print("Failed to generate image hash")
                                    }
                                } else {
                                    print("Failed to parse car details: \(result)")
                                }
                            }
                        }
                    }
                }
                
            }
            .confirmationDialog("Choose Image Source", isPresented: $showSourceSelection) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Take a photo") {
                        selectedSource = .camera
                        showImagePicker = true
                    }
                }
                Button("Choose from photo library") {
                    selectedSource = .photoLibrary
                    showImagePicker = true
                }
                
                Button("Cancel", role: .cancel) { }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: selectedSource, selectedImage: $image)
            }
        }
    }
}

#Preview {
    SnapCarPhotoView().environmentObject(AuthViewModel())
}
