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

enum UserState {
    case noHash
    case notYetLoggedIn
    case loggedIn
}

class UserController {

    private init() {

        if let keychainComponents = keychain[credentialStorageKey]?.components(separatedBy: "*"),
            keychainComponents.count == 2,
            let sessionID = keychainComponents.first,
            let expirationString = keychainComponents.last,
            let expirationDate = Formatters.isoDateFormatter.date(from: expirationString) {

            if expirationDate > Date() {
                print("Cached Session is not expired")
                cachedSession = Session(expiration: expirationDate, id: sessionID)
                return
            }
        }

        cachedSession = nil
    }

    static let shared = UserController()

    private var cachedSession: Session?

    private let credentialStorageKey = Config.Keychain.CredentialsStorageKey
    private let keychain = Keychain(service: Config.Keychain.Service)

    private let _currentUser = MutableProperty<User?>(nil)
    lazy var currentUser: Property<User?> = {
        return Property(self._currentUser)
    }()

    var isValidSession: Bool {
        if let expirationDate = cachedSession?.expiration,
            expirationDate > Date() {
            return true
        } else {
            deleteCedentials()
            return false
        }
    }

    var userSessionId: String? {
        return cachedSession?.id
    }

    var userState: UserState {
        if userSessionId == nil { return .noHash }
        return _currentUser.value == nil ? .notYetLoggedIn : .loggedIn
    }

    func saveCredentials(user: User) {
        cachedSession = user.session
        keychain[credentialStorageKey] = user.session.id + "*" + Formatters.isoDateFormatter.string(from: user.session.expiration)
        _currentUser.value = user
    }

    func deleteCedentials() {
        keychain[credentialStorageKey] = nil
        cachedSession = nil
        _currentUser.value = nil
    }

    lazy var login: Action<LoginCredentials, User, APIError> = {
        return Action { (credentials) in

            let (email, password) = credentials
            return APIClient
                .request(.postSession(email: email, password: password), type: User.self)
                .on(value: { [weak self] user in
                    guard let `self` = self else { return }
                    print("Credential saved")

                    self.saveCredentials(user: user)
                })
        }
    }()
}
