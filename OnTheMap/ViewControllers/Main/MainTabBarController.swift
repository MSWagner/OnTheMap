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
            goToAuth()
        } else {
            viewModel.refreshStudentLocations.apply(true).startWithResult { (result) in
                switch result {
                case .success(_): break
                case .failure(.producerFailed(let error)):
                    HUD.flash(.label(error.localizedError), delay: 0.8)
                case .failure(.disabled):
                    HUD.flash(.label(Strings.Network.errorActionDisabled), delay: 0.8)
                }
            }
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
            case .failure(.producerFailed(let error)):
                HUD.flash(.label(error.localizedError), delay: 0.8)
            case .failure(.disabled):
                HUD.flash(.label(Strings.Network.errorActionDisabled), delay: 0.8)
            }
        }
    }

    @IBAction func onAdd(_ sender: Any) {
        let addLocationVC: AddLocationViewController = UIStoryboard(.location).instantiateViewController()
        addLocationVC.viewModel = viewModel
        navigationController?.pushViewController(addLocationVC, animated: true)
    }

    @IBAction func onRefresh(_ sender: Any) {
        HUD.show(.progress)
        viewModel.refreshStudentLocations.apply(true).startWithResult { (result) in
            switch result {
            case .success(_):
                HUD.flash(.success)
            case .failure(.producerFailed(let error)):
                HUD.flash(.label(error.localizedError), delay: 0.8)
            case .failure(.disabled):
                HUD.flash(.label(Strings.Network.errorActionDisabled), delay: 0.8)
            }
        }
    }
}
