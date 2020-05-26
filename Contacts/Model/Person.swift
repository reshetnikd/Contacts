//
//  Person.swift
//  Contacts
//
//  Created by Dmitry Reshetnik on 26.05.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import Foundation
import UIKit

struct Root: Codable {
    let entry: [Entry]
}

struct Entry: Codable {
    let id, hash, requestHash: String
    let profileURL: URL
    let preferredUsername: String
    let thumbnailURL: URL
    let photos: [Photo]
    let displayName: String

    enum CodingKeys: String, CodingKey {
        case id, hash, requestHash
        case profileURL = "profileUrl"
        case preferredUsername
        case thumbnailURL = "thumbnailUrl"
        case photos, displayName
    }
}

struct Photo: Codable {
    let value: URL
    let type: String
}
