//
//  API.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 13.12.17.
//  Copyright © 2017 Michael Wagner. All rights reserved.
//

import Foundation

enum API {

    // Auth
    case postSession(email: String, password: String)
    case deleteSession
    case signUp

    // Public Data
    case getPublicUserData(uniqueKey: String)

    // Location
    case getStudentLocations(limit: Int?, skip: Int?, order: String?)
    case getStudentLocation(uniqueKey: String)
    case postStudentLocation(location: StudentInformation)
    case putStudentLocation(location: StudentInformation, objectID: String)
}

extension API {

    var host: String {
        switch self {
        case .postSession, .deleteSession, .signUp, .getPublicUserData:
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

        case .getPublicUserData(let uniqueKey):
            return "/api/users/\(uniqueKey)"

        case .getStudentLocations,
             .getStudentLocation,
             .postStudentLocation:
            return "/parse/classes/StudentLocation"

        case .putStudentLocation(_ , let objectID):
            return "/parse/classes/StudentLocation/\(objectID)"
        }
    }

    var url: URL {
        var components = URLComponents()
        components.scheme = Config.API.URLScheme
        components.host = host
        components.path = path

        switch self {
        case .getStudentLocations,
             .getStudentLocation:

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
        case .getStudentLocation, .getStudentLocations, .signUp, .getPublicUserData:
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

        case .deleteSession:
            var xsrfCookie: HTTPCookie? = nil
            let sharedCookieStorage = HTTPCookieStorage.shared
            for cookie in sharedCookieStorage.cookies! {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }

            return [
                "X-XSRF-TOKEN": xsrfCookie?.value ?? ""
            ]

        case .getStudentLocations,
             .getStudentLocation:

            return [
                "X-Parse-Application-Id": Config.API.ParseAppID,
                "X-Parse-REST-API-Key": Config.API.APIKey
            ]

        case .postStudentLocation, .putStudentLocation:
            return [
                "X-Parse-Application-Id": Config.API.ParseAppID,
                "X-Parse-REST-API-Key": Config.API.APIKey,
                "Content-Type": "application/json"
            ]

        default: return nil
        }
    }

    var parameters: [String: Any]? {
        switch self {

        case .getStudentLocations(let limit, _, _):
            return ["limit": limit ?? 100]

        case .getStudentLocation(let uniqueKey):
            return ["where": "{\"uniqueKey\": \"\(uniqueKey)\"}"]

        default: return nil
        }
    }

    var body: Data? {
        switch self {

        case let .postSession(email, password):
            let json = [
                "udacity": ["username": email, "password": password]
            ]
            return try? JSONSerialization.data(withJSONObject: json)

        case let .postStudentLocation(location), let .putStudentLocation(location, _):
            return try? JSONEncoder().encode(location)

        default: return nil
        }
    }

    var request: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        if let headers = headers {
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }

        if let body = body {
            request.httpBody = body
        }

        return request
    }

    var shouldSkipFirst5Chars: Bool {
        switch self {
        case .deleteSession,
             .postSession,
             .getPublicUserData:
            return true
        default:
            return false
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

