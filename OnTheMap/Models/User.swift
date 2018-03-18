//
//  User.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 14.12.17.
//  Copyright © 2017 Michael Wagner. All rights reserved.
//

import Foundation

struct User: Codable {
    let account: Account
    let session: Session
}

struct Account: Codable {
    let key: String
    let registered: Int
}

struct Session: Codable {
    let expiration: Date
    let id: String
}
