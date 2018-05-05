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

    var publicData: PublicUser?

    enum CodingKeys: String, CodingKey {
        case account
        case session
        case publicData
    }
}

struct Account: Codable {
    let key: String
    let registered: Bool
}

struct Session: Codable {
    let expiration: Date
    let id: String
}

extension User {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        account = try container.decode(Account.self, forKey: .account)
        session = try container.decode(Session.self, forKey: .session)

        publicData = try container.decodeIfPresent(PublicUser.self, forKey: .publicData)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(account, forKey: .account)
        try container.encode(session, forKey: .session)

        try container.encodeIfPresent(publicData, forKey: .publicData)
    }
}
