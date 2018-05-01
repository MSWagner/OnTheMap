//
//  StudentAnnotationView.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 01.05.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import UIKit
import MapKit

class StudentAnnotationView: MKMarkerAnnotationView {

    override var annotation: MKAnnotation? {
        willSet {
            guard newValue != nil else { return }
            clusteringIdentifier = "studentAnnotationClusterId"
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            markerTintColor = UIColor(red:0.36, green:0.80, blue:0.74, alpha:1.0)
        }
    }
}
