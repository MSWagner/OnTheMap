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

    // Custom
    case invalidURLResponse
    case udacityError(UdacityError)
    case noConnection
    case noStudentInformation

    var localizedError: LocalizedError {
        switch self {
        case .underlying(let error):
            let nsError = error as NSError
            return nsError.localizedDescription
        case .udacityError(let error):
            return error.error
        case .noConnection:
            return "No Connection"
        default:
            return APIError.defaultLocalizedError
        }
    }

    private static var defaultLocalizedError: LocalizedError = Strings.Network.errorGeneric
}

