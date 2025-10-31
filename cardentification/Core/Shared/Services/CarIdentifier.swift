//
//  CarIdentifier.swift
//  cardentification
//
//  Created by Anthony Jerez on 10/31/25.
//

import Foundation
import UIKit

struct CarMatch {
    let make: String
    let model: String
    let generation: String
    let years: String
    let probability: Double
}

protocol CarIdentifier {
    func identify(from image: UIImage) async throws -> CarMatch
}

enum CarIdentifierError: Error {
    case apiKeyMissing
    case badImageData
    case http(Int)
    case invalidResponse
    case noSelection
}

private struct CarNetResponse: Decodable {
    struct Detection: Decodable {
        struct Status: Decodable { let selected: Bool }
        struct MMG: Decodable {
            let make_name: String
            let model_name: String
            let generation_name: String
            let years: String
            let probability: Double
        }
        let status: Status
        let mmg: [MMG]?
    }
    let detections: [Detection]
}

struct CarNetIdentifier: CarIdentifier {
    private let session: URLSession = .shared
    private let endpoint = URL(string:
        "https://api.carnet.ai/v2/mmg/detect?box_offset=0&box_min_width=180&box_min_height=180&box_min_ratio=1&box_max_ratio=3.15&box_select=center&region=DEF"
    )!

    func identify(from image: UIImage) async throws -> CarMatch {
        guard let body = image.jpegData(compressionQuality: 0.8) else { throw CarIdentifierError.badImageData }
        guard let apiKey = Bundle.main.infoDictionary?["CARNET_API_KEY"] as? String else { throw CarIdentifierError.apiKeyMissing }

        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "accept")
        req.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        req.setValue(apiKey, forHTTPHeaderField: "api-key")

        let (data, resp) = try await session.upload(for: req, from: body)
        guard let http = resp as? HTTPURLResponse else { throw CarIdentifierError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw CarIdentifierError.http(http.statusCode) }

        let decoded = try JSONDecoder().decode(CarNetResponse.self, from: data)
        guard
            let det = decoded.detections.first(where: { $0.status.selected }),
            let mmg = det.mmg?.max(by: { $0.probability < $1.probability })
        else { throw CarIdentifierError.noSelection }

        return CarMatch(
            make: mmg.make_name,
            model: mmg.model_name,
            generation: mmg.generation_name,
            years: mmg.years,
            probability: mmg.probability
        )
    }
}
