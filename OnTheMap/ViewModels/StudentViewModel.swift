//
//  StudentViewModel.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 01.05.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import Foundation
import MapKit

class StudentViewModel {

    private var model: StudentInformation!

    init(model: StudentInformation) {
        self.model = model
    }

    var name: String {
        return "\(model.firstName ?? "") \(model.lastName ?? "")"
    }

    var url: String {
        return model.mediaURL ?? ""
    }

    var coordinate: CLLocationCoordinate2D? {
        guard let latitude = model.latitude, let longitude = model.longitude else { return nil }
        return CLLocationCoordinate2DMake(latitude, longitude)
    }

    var uniqueKey: String {
        return model.uniqueKey ?? ""
    }
}
