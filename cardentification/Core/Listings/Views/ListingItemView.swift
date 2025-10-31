//
//  ListingItemView.swift
//  cardentification
//
//  Created by Anthony Jerez on 4/21/25.
//

import SwiftUI

struct ListingItemView: View {
    let carPhoto: CarPhoto

    private var carSearchURL: URL? {
        URL(
            string:
              "https://www.autotrader.com/cars-for-sale/all-cars/\(carPhoto.make.lowercased())/\(carPhoto.model.lowercased())/\(carPhoto.years.components(separatedBy: "-").first ?? "")"
        )
    }

    private var generationYearsText: String {
        let a = carPhoto.generation.replacingOccurrences(of: " ", with: "")
        let b = carPhoto.years.replacingOccurrences(of: " ", with: "")
        return a.caseInsensitiveCompare(b) == .orderedSame
            ? carPhoto.generation
            : "\(carPhoto.generation)\n(\(carPhoto.years))"
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                // Car image
                AsyncImage(url: URL(string: carPhoto.imageURLString)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(.gray.opacity(0.15))
                        .overlay(ProgressView().progressViewStyle(.circular))
                }
                .frame(height: 240)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                // Confidence badge (kept blue and red for semantics)
                Text(String(format: "%.0f%%", carPhoto.probability * 100))
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(confidenceColor)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    .padding(10)
            }

            // Details
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(carPhoto.make)
                            .font(.title3.weight(.heavy))
                            .foregroundColor(.black)

                        Text(carPhoto.model)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }

                HStack(alignment: .top) {
                    Text(generationYearsText)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Theme.red.opacity(0.08))
                        .foregroundColor(Theme.red)
                        .clipShape(Capsule())

                    Spacer()

                    Text("Added: \(formattedDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let url = carSearchURL {
                    Link(destination: url) {
                        Label("Find Similar Cars For Sale Near You", systemImage: "cart")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryRedButton())
                    .padding(.top, 4)
                }
            }
        }
        .padding(12)
        .background(Theme.glassCard)
        .cornerRadius(22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Theme.cardStroke, lineWidth: 1.1)
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    private var confidenceColor: Color {
        switch carPhoto.probability {
        case 0.7...: return .blue
        default:     return .red
        }
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: carPhoto.selectedOn)
    }
}

#Preview {
    let mockPhoto = CarPhoto(
        id: UUID().uuidString,
        imageURLString: "https://images.pexels.com/photos/1402787/pexels-photo-1402787.jpeg",
        make: "Nissan",
        model: "GT-R",
        probability: 0.96,
        generation: "I (R35) facelift 3",
        years: "2016-2023",
        selectedOn: Date(),
        hash: "abc123"
    )

    return ListingItemView(carPhoto: mockPhoto)
        .padding()
        .background(Theme.backgroundGradient)
}
