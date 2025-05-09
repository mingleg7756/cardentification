//
//  ListingItemView.swift
//  cardentification
//
//  Created by Anthony Jerez on 4/21/25.
//

import SwiftUI

struct ListingItemView: View {
    let carPhoto: CarPhoto
    // Computed property to generate car search URL to access car marketplace
   private var carSearchURL: URL? {
        let searchQuery = "\(carPhoto.make)+\(carPhoto.model)+\(carPhoto.years)".replacingOccurrences(of: " ", with: "+")
        return URL(string: "https://www.autotrader.com/cars-for-sale/all-cars/\(carPhoto.make.lowercased())/\(carPhoto.model.lowercased())/\(carPhoto.years.components(separatedBy: "-").first ?? "")")
    }
    
    // shows 'generation' alone unless it's equal to 'years'
    private var generationYearsText: String {
        let genTrimmed = carPhoto.generation.replacingOccurrences(of: " ", with: "")
        let yrsTrimmed = carPhoto.years.replacingOccurrences(of: " ", with: "")
        if genTrimmed.caseInsensitiveCompare(yrsTrimmed) == .orderedSame {
            return carPhoto.generation
        } else {
            return "\(carPhoto.generation)\n(\(carPhoto.years))"
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Image section
            AsyncImage(url: URL(string: carPhoto.imageURLString)) { image in
                image
                    .resizable()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Car details section
            VStack(alignment: .leading, spacing: 16) {
                // Make and Model section
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(carPhoto.make)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(carPhoto.model)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Confidence score badge
                    ZStack {
                        Capsule()
                            .fill(confidenceColor)
                            .frame(width: 70, height: 30)
                        
                        Text(String(format: "%.0f%%", carPhoto.probability * 100))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                    }
                }
                
                // Year and Date section
                HStack {
                    Text(generationYearsText)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Text("Added: \(formattedDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Buy button section
                if let url = carSearchURL {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "cart")
                                .font(.subheadline)
                            Text("Find Similar Cars For Sale Near You")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // Change the color of the confidence score badge based on the confidence score
    private var confidenceColor: Color {
        let confidence = carPhoto.probability
        switch confidence {
        case 0.9...:
            return .green
        case 0.7...:
            return .orange
        default:
            return .red
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: carPhoto.selectedOn)
    }
}

#Preview {
    let mockPhoto = CarPhoto(
        imageURLString: "https://placeholder.com",
        make: "Toyota",
        model: "Corolla",
        probability: 0.95,
        generation: "2019-2022",
        years: "2019-2022",
        selectedOn: Date(),
        hash: "abc123"
    )
    
    return ListingItemView(carPhoto: mockPhoto)
        .padding()
}
