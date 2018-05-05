//
//  PublicUserData.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 05.05.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import Foundation

struct PublicUserData: Codable {
    let user: PublicUser
}

struct PublicUser: Codable {
    let key: String
    let last_name: String
    let first_name: String
}
