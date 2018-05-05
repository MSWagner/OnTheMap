//
//  MainViewController.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 18.03.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import UIKit
import PKHUD

class MainTabBarController: UITabBarController {

    // MARK: - Properties

    var viewModel: LocationViewModel!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = LocationViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !UserController.hasValidSession {
            print("No valid session")
            goToAuth()
        } else {
            viewModel.refreshStudentLocations.apply(true).start()
        }
    }

    // MARK: - Navigation

    private func goToAuth() {
        let loginVC: LoginViewController = UIStoryboard(.auth).instantiateViewController()
        setRootViewController(loginVC, animationOption: .transitionFlipFromBottom)
    }

    // MARK: - IBActions

    @IBAction func onLogout(_ sender: Any) {
        HUD.show(.progress)

        UserController.shared.logout.apply().startWithResult { [weak self] (result) in

            switch result {
            case .success:
                UserController.currentUser = nil
                self?.goToAuth()
                HUD.flash(.success)

            case .failure(let error):
                if case .producerFailed(let error) = error {
                    HUD.flash(.label(error.localizedError), delay: 1.0)
                } else {
                    HUD.flash(.error, delay: 0.5)
                }
            }
        }
    }

    @IBAction func onAdd(_ sender: Any) {
        let addLocationVC: AddLocationViewController = UIStoryboard(.location).instantiateViewController()
        addLocationVC.viewModel = viewModel
        navigationController?.pushViewController(addLocationVC, animated: true)
    }

    @IBAction func onRefresh(_ sender: Any) {
        viewModel.refreshStudentLocations.apply(true).start()
    }
}
