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

    // MARK: - Properties

    var viewModel: LocationViewModel!

    lazy var geocoder = CLGeocoder()

    /// KeyboardLinkedVC Property
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
        self.hideKeyboardOnTab()
        if let locationText = locationTextField.text, !locationText.isEmpty {
            HUD.show(.progress)

            viewModel.geocodeAddress
                .apply((locationText, urlTextField.text))
                .startWithResult { [weak self] (result) in

                guard let `self` = self else { return }

                switch result {
                case .success:
                    HUD.flash(.success, onView: self.view, delay: 0.4, completion: { _ in
                        let mapViewController: MapViewController = UIStoryboard(.map).instantiateViewController()
                        mapViewController.viewModel = self.viewModel
                        self.navigationController?.pushViewController(mapViewController, animated: true)
                    })
                case .failure(let error):
                    HUD.flash(.label(error.localizedDescription), delay: 0.7)
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
