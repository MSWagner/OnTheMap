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

class LoginViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var loginButton: DesignableButton!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!

    // MARK: - Properties

    private var textFieldBottomY: CGFloat = 0
    private var viewInsetForKeyboard: CGFloat = 0 {
        didSet {
            view.frame.origin.y += viewInsetForKeyboard == 0 ? oldValue : -viewInsetForKeyboard
        }
    }
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoginButton()

        SignalProducer
            .combineLatest(emailTextfield.reactive.continuousTextValues.producer, passwordTextfield.reactive.continuousTextValues.producer)
            .startWithValues { [weak self] (email, password) in
                guard let `self` = self else { return }

                if let email = email, let password = password {
                    self.loginButton.isEnabled = email.count > 0 && password.count > 0
                    return
                }
                self.loginButton.isEnabled = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tabBarController?.tabBar.isHidden = true

        subscribeToKeyboardNotifications()
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false

        unsubscribeFromKeyboardNotifications()
    }

    // MARK: - Setup UI

    private func setupLoginButton() {
        loginButton.setBackgroundColor(.lightGray, for: .disabled, animated: false, animationDuration: nil)
        loginButton.isEnabled = false
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
                print("Error: \(error.localizedDescription)")
                if case .producerFailed(let error) = error {
                    HUD.flash(.label(error.localizedError), delay: 1.0)
                } else {
                    HUD.flash(.error, delay: 0.5)
                }
            }
        }
    }

    // MARK: - Keyboard Functions

    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }

    private func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)

        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

    @objc private func keyboardWillShow(_ notification:Notification) {
        let keyboardTopYAxis = getKeyboardTopYAxis(notification)

        viewInsetForKeyboard = textFieldBottomY > keyboardTopYAxis ? textFieldBottomY - keyboardTopYAxis - 15 : 0
    }

    @objc private func keyboardWillHide(_ notification:Notification) {
        viewInsetForKeyboard = 0
    }

    private func getKeyboardTopYAxis(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue

        return view.frame.height - keyboardSize.cgRectValue.height
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldBottomY = textField.frame.origin.y + 50
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldBottomY = 0
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
}

