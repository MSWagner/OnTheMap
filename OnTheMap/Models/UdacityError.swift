//
//  UdacityError.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 18.03.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import Foundation

struct UdacityError: Codable {
    let status: Int
    let error: String
}
