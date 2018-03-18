//
//  Config.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 03.03.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import Foundation

struct Config {

    struct API {
        static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ParseAppID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"

        static let URLScheme = "https"
    }

    struct Keychain {
        static let Service = "com.mwswagner.onthemap"
        static let CredentialsStorageKey = "Credentials"
    }
}
