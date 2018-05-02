//
//  Notification+Parse.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 02.05.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import Foundation
import UIKit

extension Notification {

    func parse() -> (CGFloat, TimeInterval, UIViewAnimationOptions)? {

        guard let info = self.userInfo else { return nil }
        guard let height = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return nil }
        guard let duration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return nil }
        guard let curveRaw = info[UIKeyboardAnimationCurveUserInfoKey] as? Int else { return nil }

        let curve = UIViewAnimationOptions(rawValue: UInt(curveRaw) << 16)

        return (height, duration, curve)
    }
}
