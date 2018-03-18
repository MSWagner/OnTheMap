//
//  MainRootViewController.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 18.03.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import UIKit

class MainRootViewController: UIViewController {

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Navigation

    private func goToAuth() {
        let loginViewController: LoginViewController = UIStoryboard(.auth).instantiateViewController()
        setRootViewController(loginViewController, animationOption: .transitionFlipFromBottom)
    }

    // MARK: - IBActions

    @IBAction func onLogout(_ sender: Any) {
        UserController.shared.deleteCedentials()
        goToAuth()
    }

    @IBAction func onAdd(_ sender: Any) {
    }

    @IBAction func onRefresh(_ sender: Any) {
    }
}
