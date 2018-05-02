//
//  DesignableButtonProtocol.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 02.05.18.
//  Copyright © 2018 Michael Wagner. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

protocol DesignableButtonProtocol {
    func setupDesignableButton(_ button: DesignableButton)
    func disableButton(_ button: DesignableButton, untilTextFieldNotEmpty textFields: [UITextField])
}

extension DesignableButtonProtocol where Self: UIViewController {

    func setupDesignableButton(_ button: DesignableButton) {
        button.setBackgroundColor(.lightGray, for: .disabled, animated: false, animationDuration: nil)
        button.isEnabled = false
    }

    func disableButton(_ button: DesignableButton, untilTextFieldNotEmpty textFields: [UITextField]) {

        let textFieldProducers = textFields.map { $0.reactive.continuousTextValues.producer }

        SignalProducer
            .combineLatest(textFieldProducers)
            .startWithValues { textFieldValues in
                button.isEnabled = textFieldValues
                    .compactMap { $0 }
                    .filter { !$0.isEmpty }
                    .count == textFields.count
        }
    }
}

