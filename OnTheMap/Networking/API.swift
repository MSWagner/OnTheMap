//
//  API.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 13.12.17.
//  Copyright © 2017 Michael Wagner. All rights reserved.
//

import Foundation

enum API {

    // MARK: Auth

    case postSession(email: String, password: String)
    case deleteSession
    case signUp

    // MARK: Location

    case getStudentLocations(limit: Int?, skip: Int?, order: String?)
    case getStudentLocation
    case postStudentLocation(location: StudentInformation)
    case putStudentLocation(location: StudentInformation, objectID: String)
}

extension API {

    var host: String {
        switch self {
        case .postSession, .deleteSession, .signUp:
            return "www.udacity.com"

        case .getStudentLocations,
             .getStudentLocation,
             .postStudentLocation,
             .putStudentLocation:
            return "parse.udacity.com"
        }
    }

    var path: String {
        switch self {
        case .postSession,
             .deleteSession:
            return "/api/session"

        case .signUp:
            return "/account"

        case .getStudentLocations,
             .getStudentLocation,
             .postStudentLocation:
            return "parse/classes/StudentLocation"

        case .putStudentLocation(_ , let objectID):
            return "parse/classes/StudentLocation/\(objectID)"
        }
    }

    var url: URL {
        var components = URLComponents()
        components.scheme = Config.API.URLScheme
        components.host = host
        components.path = path

        switch self {
        case .getStudentLocations,
             .getStudentLocation,
             .postStudentLocation,
             .putStudentLocation:

            components.queryItems = [URLQueryItem]()

            if let parameters = parameters {
                for (key, value) in parameters {
                    let queryItem = URLQueryItem(name: key, value: "\(value)")
                    components.queryItems!.append(queryItem)
                }
            }
        default: break
        }
        return components.url!
    }

    var method: HTTPMethod {
        switch self {
        case .getStudentLocation, .getStudentLocations, .signUp:
            return .get
        case .deleteSession:
            return .delete
        case .postSession, .postStudentLocation:
            return .post
        case .putStudentLocation:
            return .put
        }
    }

    var headers: [String: String]? {
        switch self {

        case .postSession(_ ):
            return [
                "Accept": "application/json",
                "Content-Type": "application/json"
            ]

        default: return nil
        }
    }

    var parameters: [String: Any]? {
        switch self {

        case .getStudentLocations:
            return ["limit": 100, "skip": 400]

        case .getStudentLocation:
            return ["where": ["uniqueKey": 123]]

        default: return nil
        }
    }

    var body: [String: Any]? {
        switch self {

        case let .postSession(email, password):
            return [
                "udacity": ["username": email, "password": password]
            ]

        case let .postStudentLocation(location), let .putStudentLocation(location, _):
            return [
                "uniqueKey": location.uniqueKey,
                "firstName": location.firstName,
                "lastName": location.lastName,
                "mapString": location.mapString,
                "mediaURL": location.mediaURL,
                "latitude": location.latitude,
                "longitude": location.longitude
            ]

        default: return nil
        }
    }

    var request: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.string

        if let headers = headers {
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        return request
    }

    func addApiKeyAndIDToHeader(headerField: [String: String]) -> [String: String] {
        var tempHeaderField = headerField
        tempHeaderField[Config.API.ParseAppID] = "X-Parse-Application-Id"
        tempHeaderField[Config.API.APIKey] = "X-Parse-REST-API-Key"
        return tempHeaderField
    }
}

enum HTTPMethod {
    case get
    case post
    case put
    case delete

    var string: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        case .delete: return "DELETE"
        }
    }
}

