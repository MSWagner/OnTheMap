//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 13.12.17.
//  Copyright © 2017 Michael Wagner. All rights reserved.
//

import Foundation

struct StudentInformation: Codable {
    var objectId: String

    var uniqueKey: String

    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String

    var latitude: Double
    var longitude: Double

    var createdAt: Date
    var updatedAt: Date
}
