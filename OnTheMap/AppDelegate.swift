//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 10.12.17.
//  Copyright © 2017 Michael Wagner. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        Appearance.setup()

        if !UserController.hasValidSession {

            let authViewController: LoginViewController = UIStoryboard(.auth).instantiateViewController()

            window?.rootViewController = authViewController
            UIApplication.shared.keyWindow?.rootViewController = authViewController
            UIApplication.shared.keyWindow?.makeKeyAndVisible()
        }

        return true
    }
}

