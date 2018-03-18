//
//  LoginButton.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 18.03.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import UIKit
import SimpleButton

class LoginButton: SimpleButton {
    override func configureButtonStyles() {
        super.configureButtonStyles()
        setBackgroundColor(.lightGray, for: .disabled)
    }
}
