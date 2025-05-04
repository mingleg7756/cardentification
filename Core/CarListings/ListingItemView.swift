//
//  ListingItemView.swift
//  cardentification
//
//  Created by Anthony Jerez on 4/21/25.
//

import SwiftUI

struct ListingItemView: View {
    let carPhoto: CarPhoto
    
    var body: some View {
        VStack(spacing: 8) {
            // image
            AsyncImage(url: URL(string: carPhoto.imageURLString)) { image in
                image
                    .resizable()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // listing details
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(carPhoto.make)
                    
                    Text(carPhoto.model)
                    
                    Text(carPhoto.years)
                    
                }
                
                Spacer()
                
                Text(String(format: "%.2f%%", carPhoto.probability * 100))
                
            }
            .font(.footnote)
        }
    }
}

#Preview {
    let mockPhoto = CarPhoto(
        imageURLString: "https://placeholder.com",
        make: "Toyota",
        model: "Corolla",
        probability: 0.95,
        years: "2019–2022",
        selectedOn: Date(),
        hash: "abc123"
    )
    
    return ListingItemView(carPhoto: mockPhoto)
}
