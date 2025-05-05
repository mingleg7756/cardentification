//
//  CarPhoto.swift
//  cardentification
//
//  Created by Anthony Jerez on 4/19/25.
//

import Foundation

struct CarPhoto: Codable, Identifiable {
    var id: String = UUID().uuidString
    var imageURLString: String
    let make: String
    let model: String
    let probability: Double
    let generation: String
    let years: String
    var selectedOn: Date
    let hash: String
}
