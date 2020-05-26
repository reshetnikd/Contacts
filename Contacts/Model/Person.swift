//
//  Person.swift
//  Contacts
//
//  Created by Dmitry Reshetnik on 26.05.2020.
//  Copyright © 2020 Dmitry Reshetnik. All rights reserved.
//

import Foundation
import CommonCrypto
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

struct Person {
    enum PersonUpdate {
        case delete(Int)
        case insert(Person, Int)
        case move(Int, Int)
        case reload(Int)
        case rename(Int)
    }
    
    var name: String
    var email: String
    var status: Bool
    var avatar: UIImage
    
    static func fetchDataOfProfile(with email: String, avatarSize size: CGFloat = 100, scale: CGFloat = UIScreen.main.scale) -> Person {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let hash = trimmed.lowercased().md5_hash
        let url = "https://www.gravatar.com/\(hash).json"
        let fileURL = URL(string: url)
        
        do {
            let contents = try String(contentsOf: fileURL!)
            let data = contents.data(using: String.Encoding.utf8)
            let decoder = JSONDecoder()
            let root = try decoder.decode(Root.self, from: data!)
            let imageURL = root.entry[0].photos.first!.value
            let query = URLQueryItem(name: "s", value: String(format: "%.0f",size * scale))
            
            var components = URLComponents(url: imageURL, resolvingAgainstBaseURL: false)!
            components.queryItems = [query]
            
            let imageData = try Data(contentsOf: components.url!)
            
            let name = root.entry[0].displayName
            let email = email
            let status = Bool.random()
            let avatar = UIImage(data: imageData)!
            
            return Person(name: name, email: email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines), status: status, avatar: avatar)
        } catch {
            print("Error parsing JSON.")
            let imageConfig = UIImage.SymbolConfiguration(scale: .large)
            let defaultImage = UIImage(systemName: "person.crop.circle", withConfiguration: imageConfig)
            return Person(name: "Person Name", email: "person@server.com", status: false, avatar: defaultImage!)
        }
    }
}

private extension String  {
    var md5_hash: String {
        let trimmedString = lowercased().trimmingCharacters(in: CharacterSet.whitespaces)
        let utf8String = trimmedString.cString(using: String.Encoding.utf8)!
        let stringLength = CC_LONG(trimmedString.lengthOfBytes(using: String.Encoding.utf8))
        let digestLength = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLength)

        CC_MD5(utf8String, stringLength, result)

        var hash = ""

        for i in 0..<digestLength {
            hash += String(format: "%02x", result[i])
        }

        result.deallocate()

        return String(format: hash)
    }
}
