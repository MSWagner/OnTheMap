//
//  SignUpWebVC.swift
//  OnTheMap
//
//  Created by Matthias Wagner on 14.12.17.
//  Copyright © 2017 Michael Wagner. All rights reserved.
//

import UIKit
import WebKit

class SignUpWebVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var webView: WKWebView!
    
    // MARK: - Properties

    var urlRequest: URLRequest? = nil

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelAuth))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let urlRequest = urlRequest {
            webView.load(urlRequest)
        }
    }

    // MARK: - Navigation Functions

    @objc func cancelAuth() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - WKNavigationDelegate
extension SignUpWebVC: WKNavigationDelegate {


}
