//
//  User.swift
//  cardentification
//
//  Created by Anthony Jerez on 4/18/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let fullName: String
    let email: String
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullName) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
        
    }
}

extension User {
    static var MOCK_USER = User(id: NSUUID().uuidString, fullName: "John Doe", email: "test@gmail.com")
}
