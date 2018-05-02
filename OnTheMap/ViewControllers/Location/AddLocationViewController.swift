//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 02.05.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import UIKit
import PKHUD
import CoreLocation

class AddLocationViewController: UIViewController, KeyboardNotificationProtocol, DesignableButtonProtocol {

    // MARK: - IBOutlets

    @IBOutlet weak var topConstraintForKeyboard: NSLayoutConstraint!

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var findLocationButton: DesignableButton!

    lazy var geocoder = CLGeocoder()

    // MARK: - KeyboardLinkedVC Property

    var lowestViewOverTheKeyboard: UIView?

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        /// KeyboardNotificationProtocol
        lowestViewOverTheKeyboard = findLocationButton
        bindViewOnKeyboardNotifications()

        /// DesignableButtonProtocol
        setupDesignableButton(findLocationButton)
        disableButton(findLocationButton, untilTextFieldNotEmpty: [locationTextField])

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardOnTab))
        view.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        locationTextField.delegate = self
        urlTextField.delegate = self
    }

    // MARK: - IBActions

    @IBAction func onFindLocation(_ sender: Any) {
        if let text = locationTextField.text, !text.isEmpty {

            let failure = {
                HUD.flash(.label("No places found"), delay: 0.4)
            }

            geocoder.geocodeAddressString(text) { [weak self] (placeMarks, error) in
                print("in geocoder with \(String(describing: placeMarks?.first?.location?.coordinate.latitude)) placemarks")

                if let error = error {
                    HUD.flash(.label(error.localizedDescription), delay: 0.8)
                    return
                } else if let placeMarks = placeMarks, placeMarks.count > 0 {

                    let firstPlaceMarkWithCoordinate = placeMarks
                        .compactMap{ $0.location?.coordinate }
                            .first

                    if let firstPlaceMarkWithCoordinate = firstPlaceMarkWithCoordinate {
                        let mapVC: MapViewController = UIStoryboard(.map).instantiateViewController()
                        self?.navigationController?.pushViewController(mapVC, animated: true)
                    } else {
                        failure()
                    }
                } else {
                    failure()
                }
            }
        } else {
            HUD.flash(.error, delay: 0.4)
        }
    }

    // MARK: - Keyboard

    @objc private func hideKeyboardOnTab() {
        view.endEditing(true)
    }
}

extension AddLocationViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.isEqual(urlTextField), let text = textField.text, text.isEmpty {
            textField.text = "https://"
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.isEqual(urlTextField), let text = textField.text, !text.isEmpty {
            textField.text = text.isEqualToDiffable("https://") ? "" : text
        }
    }
}
