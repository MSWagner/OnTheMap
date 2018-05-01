//
//  Appearance.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 01.05.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import UIKit

struct Appearance {
    static func setup() {
        UINavigationBar.appearance().barTintColor = UIColor(red:0.38, green:0.71, blue:0.98, alpha:1.0)
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
    }
}
