//  ContentView.swift
//  cardentification
//
//  Created by Tim Cook on 4/14/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var showCamera = false
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
            
            Button("Take a photo") {
                showCamera = true
            }
            .font(.title2)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera, selectedImage: $image)
        }
    }
}

#Preview {
    ContentView()
}
