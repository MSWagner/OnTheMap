//
//  NavigationViewController+PreviousVC.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 05.05.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import UIKit

extension UINavigationController {

    func lastViewController() -> UIViewController? {

        let vcCount = self.viewControllers.count

        return vcCount >= 2 ? self.viewControllers[vcCount - 2] : nil
    }
}
