//
//  UIViewController.swift
//  TreatMe
//
//  Created by Keilan Jackson on 10/29/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTapped() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
}
