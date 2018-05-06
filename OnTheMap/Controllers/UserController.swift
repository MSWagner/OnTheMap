//
//  UserController.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 06.03.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import Foundation
import KeychainAccess
import ReactiveSwift
import Result

typealias LoginCredentials = (String, String)
typealias UniqueKey = String

enum UserState {
    case noHash
    case notYetLoggedIn
    case loggedIn
}

class UserController: NSObject {

    static let shared = UserController()

    // MARK: Static

    fileprivate static let keychain = Keychain(service: Config.keyPrefix)
    fileprivate static let userStorageKey = Config.Keychain.credentialsStorageKey
    fileprivate static var cachedUser: User?

    static var currentUser: User? {
        get {
            if let userKeychain = keychain[data: userStorageKey],
                let userData = NSKeyedUnarchiver.unarchiveObject(with: userKeychain) as? Data, cachedUser == nil,
                let user = try? JSONDecoder().decode(User.self, from: userData) {
                cachedUser = user

                if user.publicData == nil {
                    UserController.shared.getPublicData.apply(user.account.key).start()
                }

                return user
            } else {
                return cachedUser
            }
        }
        set {
            if let user = newValue {
                let userData = try! JSONEncoder().encode(user)
                keychain[data: userStorageKey] = NSKeyedArchiver.archivedData(withRootObject: userData)
                cachedUser = user
            } else {
                cachedUser = nil
                _ = try? keychain.remove(userStorageKey)
            }
        }
    }

    static var hasValidSession: Bool {
        if let currentUser = currentUser {
            let expirationDate = currentUser.session.expiration
            return expirationDate > Date()
        } else {
            return false
        }
    }

    static func deleteCredentials() {
        UserController.shared.logout.apply().start()
        currentUser = nil
    }

    // MARK: - Auth Functions

    lazy var login: Action<LoginCredentials, User, APIError> = {
        return Action { (credentials) in

            let (email, password) = credentials
            return APIClient
                .request(.postSession(email: email, password: password), type: User.self)
                .on(value: { user in
                    UserController.shared.getPublicData.apply(user.account.key).start()
                    UserController.currentUser = user
                })
        }
    }()

    lazy var logout: Action<Void, RequestResponse, APIError> = {
        return Action {
            return APIClient.request(.deleteSession)
        }
    }()

    // MARK: - Public Data

    lazy var getPublicData: Action<UniqueKey, PublicUserData, APIError> = {

        return Action { uniqueKey in
            APIClient
                .request(.getPublicUserData(uniqueKey: uniqueKey), type: PublicUserData.self)
                .on(value: { publicData in
                    var newUser = UserController.currentUser
                    newUser?.publicData = publicData.user

                    UserController.currentUser = newUser
                })
        }
    }()
}
