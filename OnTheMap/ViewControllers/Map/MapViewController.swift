//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 18.03.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import UIKit
import MapKit
import PKHUD

class MapViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var sendLocationButton: UIButton!

    // MARK: - Properties

    var viewModel: LocationViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.showsUserLocation = true

        mapView.register(StudentAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(StudentAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)

        if let parentTabBar = tabBarController as? MainTabBarController {
            sendLocationButton.isHidden = true
            viewModel = parentTabBar.viewModel
            bindViewModel()
        }

        if let _ = navigationController?.lastViewController() as? AddLocationViewController,
            let ownStudentViewModel = viewModel.ownStudentViewModel {
            sendLocationButton.isHidden = false

            let ownAnnotation = StudentAnnotation(studentViewModel: ownStudentViewModel)

            let degree: CLLocationDegrees = 0.05
            let span = MKCoordinateSpanMake(degree, degree)
            let location = CLLocationCoordinate2DMake(ownAnnotation.coordinate.latitude, ownAnnotation.coordinate.longitude)
            let region = MKCoordinateRegionMake(location, span)

            self.mapView.addAnnotation(ownAnnotation)
            mapView.setRegion(region, animated: false)
        }
    }

    // MARK: - Datasource

    private func bindViewModel() {
        viewModel.studentViewModels.producer.startWithValues { [weak self] (studentViewModels) in
            guard let `self` = self else { return }

            let studentAnnotations = studentViewModels
                .filter { $0.coordinate != nil }
                .map { StudentAnnotation.init(studentViewModel: $0) }

            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(studentAnnotations)
        }
    }

    // MARK: - IBActions

    @IBAction func onSendLocation(_ sender: Any) {
        HUD.show(.progress)

        viewModel.uploadNewStudentLocation.apply().startWithResult { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case .success:
                HUD.flash(.success, onView: self.view, delay: 0.4, completion: { _ in
                    self.navigationController?.popToRootViewController(animated: true)
                })
            case .failure(_):
                HUD.flash(.label(Strings.Network.errorPostingFailed), delay: 0.8)
            }
        }
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        var reuseID: String

        if annotation is StudentAnnotation {
            reuseID = "singleAnnotation"
        } else if annotation is MKClusterAnnotation {
            reuseID = "clusterAnnotation"
        } else {
            return nil
        }

        var annotationView: StudentAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? StudentAnnotationView {
          dequeuedView.annotation = annotation
          annotationView = dequeuedView
        } else {
          annotationView = StudentAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        }
        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        var mediaUrl: String?

        if let clusterAnnotation = annotationView.annotation as? MKClusterAnnotation,
            let firstStudentAnnotation = clusterAnnotation.memberAnnotations.first as? StudentAnnotation {
            mediaUrl = firstStudentAnnotation.mediaURL
        } else if let studentAnnotation = annotationView.annotation as? StudentAnnotation {
            mediaUrl = studentAnnotation.mediaURL
        }

        if let mediaUrl = mediaUrl, let url =  URL(string: mediaUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: { (hasOpened) in
                if !hasOpened {
                    HUD.flash(.label(Strings.StudentInformation.errorMediaUrl), delay: 0.4)
                }
            })
        } else {
            HUD.flash(.label(Strings.StudentInformation.errorMediaUrl), delay: 0.4)
        }
    }
}
