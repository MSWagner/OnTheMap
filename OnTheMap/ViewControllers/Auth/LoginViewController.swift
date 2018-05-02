//
//  ViewController.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 10.12.17.
//  Copyright © 2017 Michael Wagner. All rights reserved.
//

import UIKit
import PKHUD
import Result
import ReactiveSwift
import ReactiveCocoa
import SimpleButton

class LoginViewController: UIViewController, KeyboardNotificationProtocol, DesignableButtonProtocol {

    // MARK: - IBOutlets

    @IBOutlet weak var loginButton: DesignableButton!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!

    // MARK: - KeyboardLinkedVC Property

    var lowestViewOverTheKeyboard: UIView?
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        /// KeyboardNotificationProtocol
        lowestViewOverTheKeyboard = loginButton
        bindViewOnKeyboardNotifications()

        /// DesignableButtonProtocol
        setupDesignableButton(loginButton)
        disableButton(loginButton, untilTextFieldNotEmpty: [emailTextfield, passwordTextfield])

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardOnTab))
        view.addGestureRecognizer(tap)
    }

    // MARK: - Navigation

    private func goToMain() {
        let mainTabbarViewController: UINavigationController = UIStoryboard(.main).instantiateViewController()
        setRootViewController(mainTabbarViewController)
    }

    // MARK: - IBActions

    @IBAction func onSignIn(_ sender: Any) {
        guard let email = emailTextfield.text, !email.isEmpty,
                let password = passwordTextfield.text, !password.isEmpty else {
            HUD.flash(.error, delay: 0.5)
            return
        }

        login(credentials: (email, password))
    }

    @IBAction func onSignUp(_ sender: Any) {
        let url = API.signUp.url

        UIApplication.shared.open(url, options: [:])
    }

    // MARK: - Login

    private func login(credentials: LoginCredentials) {
        loginButton.isLoading = true

        UserController.shared.login.apply(credentials).startWithResult { [weak self] (result) in
            guard let `self` = self else { return }

            self.loginButton.isLoading = false

            switch result {
            case .success(_):
                HUD.flash(.success, delay: 0.5)
                self.goToMain()

            case .failure(let error):
                if case .producerFailed(let error) = error {
                    HUD.flash(.label(error.localizedError), delay: 1.0)
                } else {
                    HUD.flash(.error, delay: 0.5)
                }
            }
        }
    }

    // MARK: - Keyboard

    @objc private func hideKeyboardOnTab() {
        view.endEditing(true)
    }
}


