//
//  Strings.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 06.03.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import Foundation

// swiftlint:disable line_length
public struct Strings {

    public struct App {
        static let name = Strings.localized("app_name", value: "OnTheMap", comment: "name of the app")
    }

    public struct Network {
        static let errorGeneric = Strings.localized("network_error_generic", value: "An error has occurred.")
        static let errorLoadingFailed = Strings.localized("network_error_loading_failed", value: "Could not load data. (Code %1$@)")
        static let errorNoConnection = Strings.localized("network_error_no_connection", value: "No network connection. Please try again later.")
        static let errorPostingFailed = Strings.localized("network_error_posting_failed", value: "Data could not be transferred. (Code %1$@)")
        static let errorWrongCredentials = Strings.localized("network_error_wrong_credentials", value: "You entered an incorrect username or a wrong password. Please try again.")
    }

    // settings this closure allows you to use a custom localization provider, such as OneSky over-the-air
    // by default, NSLocalizedString will load the strings from the main bundle's Localizable.strings file
    public static var customLocalizationClosure: ((String, String?, Bundle, String, String) -> String)? = nil

    public static func localized(_ key: String, tableName: String? = nil, bundle: Bundle = Bundle.main, value: String, comment: String = "") -> String {
        if let closure = Strings.customLocalizationClosure {
            return closure(key, tableName, bundle, value, comment)
        } else {
            return NSLocalizedString(key, tableName: tableName, bundle: bundle, value: value, comment: comment)
        }
    }
}


