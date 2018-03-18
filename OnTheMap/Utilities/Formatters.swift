//
//  DateFormatter.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 18.03.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import Foundation

struct Formatters {
    static let isoDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"
        return formatter
    }()
}
