//  ContentView.swift
//  cardentification
//
//  Created by Tim Cook on 4/14/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var showImagePicker = false
    @State private var selectedSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var showSourceSelection = false
    @State private var image: UIImage?
    
    var body: some View {
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
        }
        Button("Identify Car") {
            if let image = image {
                CarNetAPI.identifyCar(image: image) { result in
                    DispatchQueue.main.async {
                        print(result)
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

#Preview {
    ContentView()
}
