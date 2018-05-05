//
//  KeyboardLinkedVCProtocol.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 02.05.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

protocol KeyboardNotificationProtocol: class {
    var lowestViewOverTheKeyboard: UIView? { get set }

    func bindViewOnKeyboardNotifications()
}

extension KeyboardNotificationProtocol where Self: UIViewController {

    func bindViewOnKeyboardNotifications() {
        guard let lowestViewOverTheKeyboard = self.lowestViewOverTheKeyboard else { return }

        let center = NotificationCenter.default.reactive

        center.notifications(forName: .UIKeyboardWillShow).map{ $0.parse() }.skipNil().observe { [weak self] notificationSignal in
            guard let value = notificationSignal.value else { return }
            guard let `self` = self else { return }

            let lowestYValueOverTheKeyboard = lowestViewOverTheKeyboard.frame.origin.y
                                            + lowestViewOverTheKeyboard.frame.height

            let viewHeight = self.view.frame.height

            let keyBoardHeight = value.0
            let keyboardTopYValue = viewHeight - keyBoardHeight

            let topOffset: CGFloat = self.view.safeAreaInsets.top == 20 ? -20 : 0

            self.view.frame.origin.y = lowestYValueOverTheKeyboard > keyboardTopYValue
                                     ? -(lowestYValueOverTheKeyboard - keyboardTopYValue + topOffset + 5 )
                                     : 0
        }

        center.notifications(forName: .UIKeyboardWillHide).observe { [weak self] _ in
            guard let `self` = self else { return }

            self.view.frame.origin.y = 0
        }
    }
}
