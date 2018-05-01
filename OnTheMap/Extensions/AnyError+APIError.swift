//
//  AnyError+APIError.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 26.04.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import Foundation
import Result

extension AnyError {
    func toAPIError() -> APIError {
        if let apiError = self.error as? APIError {
            return apiError
        }

        return APIError.underlying(self.error)
    }
}
