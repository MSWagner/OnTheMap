//
//  ViewController+AnimateRootViewController.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 18.03.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import UIKit

extension UIViewController {

    func setRootViewController(_ newRoot: UIViewController, animationOption: UIViewAnimationOptions = .transitionFlipFromTop) {
        guard let window = UIApplication.shared.keyWindow else { return }

        newRoot.view.frame = view.frame
        newRoot.view.layoutIfNeeded()

        UIView.transition(with: window, duration: 0.5, options: animationOption, animations: {
            window.rootViewController = newRoot
        }, completion: nil)
    }
}
