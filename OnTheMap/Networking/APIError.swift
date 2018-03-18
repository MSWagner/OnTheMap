//
//  APIError.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 06.03.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import Foundation

typealias LocalizedError = String //(title: String, message: String)

enum APIError: Swift.Error {

    // Underlying
    case underlying(Swift.Error)

    // Error Messages
    case invalidURLResponse
    case udacityError(UdacityError)
    case noConnection




    var localizedError: LocalizedError {
        switch self {
        case .underlying(let error):
            print("underlying")
            return error.localizedDescription
        case .udacityError(let error):
            print("udacityError")
            return error.error
        case .noConnection:
            return "No Connection"
        default:
            print("default")
            return APIError.defaultLocalizedError
        }
    }

    var statusCode: Int? {
        switch self {
        case let .underlying(error):
            print(error)
            let nsError = error as NSError
            return nsError.code
        default:
            return nil
        }
    }

    // MARK: Helper

    private func localizedNetworkErrorStatusCode(statusCode: Int, target: API) -> LocalizedError {
        switch (target, statusCode) {

        case (.postSession, 422), (.postSession, 400):
            return Strings.Network.errorWrongCredentials

        default:
            if target.method == .get {
                return String(format: Strings.Network.errorLoadingFailed, "\(statusCode)")
            }
            return String(format: Strings.Network.errorPostingFailed, "\(statusCode)")
        }
    }

    private static var defaultLocalizedError: LocalizedError = Strings.Network.errorGeneric
}

