//
//  StudentAnnotation.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 01.05.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import MapKit

class StudentAnnotation: NSObject, MKAnnotation {

    // MARK: - MKAnnotation Properties

    let coordinate: CLLocationCoordinate2D
    let title: String?
    var subtitle: String? {
        return mediaURL
    }

    // MARK: - Student Properties

    let mediaURL: String

    // MARK: Init

    init(studentViewModel: StudentViewModel) {
        title = studentViewModel.name
        mediaURL = studentViewModel.url
        coordinate = studentViewModel.coordinate!
    }
}
