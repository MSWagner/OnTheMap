//
//  GeoCodeError.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 05.05.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import Foundation


enum GeoCodeError: Swift.Error {

    case underlying(Swift.Error)

    case noValuesIncluded
    case missingUserData

    var localizedError: LocalizedError {
        switch self {
        case .underlying(let error):
            let nsError = error as NSError
            return nsError.localizedDescription
        case .noValuesIncluded, .missingUserData:
            return Strings.GeoCoding.errorEmptyResult
        }
    }
}
