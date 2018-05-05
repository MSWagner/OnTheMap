//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 13.12.17.
//  Copyright © 2017 Michael Wagner. All rights reserved.
//

import Foundation

struct StudentInformations: Codable {
    var results: [StudentInformation]
}

struct StudentInformation: Codable {
    var objectId: String?
    var uniqueKey: String?

    var firstName: String?
    var lastName: String?
    var mapString: String?
    var mediaURL: String?

    var latitude: Double?
    var longitude: Double?

    var createdAt: Date?
    var updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case objectId
        case uniqueKey

        case firstName
        case lastName
        case mapString
        case mediaURL

        case latitude
        case longitude

        case createdAt
        case updatedAt
    }
}

extension StudentInformation {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(objectId, forKey: .objectId)
        try container.encodeIfPresent(uniqueKey, forKey: .uniqueKey)

        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(mapString, forKey: .mapString)
        try container.encodeIfPresent(mediaURL, forKey: .mediaURL)

        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
    }
}
