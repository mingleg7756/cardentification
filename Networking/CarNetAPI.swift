//
//  CarNetAPI.swift
//  cardentification
//
//  Created by Anthony Jerez on 4/17/25.
//

import UIKit

struct CarNetAPI {
    static func identifyCar(image: UIImage, completion: @escaping (String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion("Error: Could not convert image to JPEG")
            return
        }
        let urlString = "https://api.carnet.ai/v2/mmg/detect?box_offset=0&box_min_width=180&box_min_height=180&box_min_ratio=1&box_max_ratio=3.15&box_select=center&region=DEF"
        guard let url = URL(string: urlString) else {
            completion("Error: Invalid URL")
            return
        }
        guard let apiKey = Bundle.main.infoDictionary?["CARNET_API_KEY"] as? String else {
            completion("Error: API Key not found")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "api-key")

        let task = URLSession.shared.uploadTask(with: request, from: imageData) { data, response, error in
            if let error = error {
                completion("Request error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion("Invalid response")
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion("HTTP Error: \(httpResponse.statusCode)")
                return
            }
            
            guard let data = data else {
                completion("No data received")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let detections = json["detections"] as? [[String: Any]] {
                    for detection in detections {
                        if let status = detection["status"] as? [String: Any],
                           let selected = status["selected"] as? Bool, selected,
                           let mmg = detection["mmg"] as? [[String: Any]],
                           let topMatch = mmg.max(by: { ($0["probability"] as? Double ?? 0.0) < ($1["probability"] as? Double ?? 0.0) }),
                           let make = topMatch["make_name"] as? String,
                           let model = topMatch["model_name"] as? String,
                           let probability = topMatch["probability"] as? Double,
                           let years = topMatch["years"] as? String {
                            let resultString = "\(make),\(model),\(years),\(probability)"
                            completion(resultString)
                            return
                        }
                    }
                    completion("No recognizable car found")
                } else {
                    completion("Unexpected response format")
                }
            } catch {
                completion("JSON error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
}
