//
//  RegisterViewController.swift
//  TreatMe
//
//  Created by Keilan Jackson on 2/27/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import UIKit
import PromiseKit

enum RegistrationStep {
    case email
    case name
    case username
    case password
}

class RegisterViewController: UIViewController, UITextFieldDelegate {

    var stepsCompleted: [RegistrationStep] = []
    let orderedSteps: [RegistrationStep] = [.email, .name, .username, .password]

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var formView: UIView!

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!

    let formViewPadding: CGFloat = 20.0
    var formBottomConstraint: NSLayoutConstraint? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        [
            emailField,
            firstNameField,
            lastNameField,
            usernameField,
            passwordField,
            confirmPasswordField
        ].forEach { field in
            field?.delegate = self
            field?.returnKeyType = .done
        }

        nextButton.setTitleColor(UIColor.TMBlue(), for: UIControlState())
        nextButton.setTitleColor(UIColor.TMBlue().withAlphaComponent(0.5), for: .disabled)
        errorLabel.textColor = UIColor.TMRed()

        errorLabel.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
        adjustFormHeight()
    }

    func adjustFormHeight() {
        if let bottom = formBottomConstraint {
            formView.removeConstraint(bottom)
        }

        if stepsCompleted.contains(.password) {

        } else if stepsCompleted.contains(.username) {
            formBottomConstraint = NSLayoutConstraint(item: formView, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: confirmPasswordField, attribute: .bottom, multiplier: 1.0, constant: formViewPadding)
        } else if stepsCompleted.contains(.name) {
            formBottomConstraint = NSLayoutConstraint(item: formView, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: usernameField, attribute: .bottom, multiplier: 1.0, constant: formViewPadding)
        } else if stepsCompleted.contains(.email) {
            formBottomConstraint = NSLayoutConstraint(item: formView, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: firstNameField, attribute: .bottom, multiplier: 1.0, constant: formViewPadding)
        } else {
            formBottomConstraint = NSLayoutConstraint(item: formView, attribute: .bottom, relatedBy: .greaterThanOrEqual, toItem: emailField, attribute: .bottom, multiplier: 1.0, constant: formViewPadding)
        }

        if let bottom = formBottomConstraint {
            formView.addConstraint(bottom)
        }

        if !stepsCompleted.isEmpty {
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            }) 
        }
    }

    func validateStep(_ step: RegistrationStep) -> Promise<Bool> {
        switch step {
        case .email:
            if let email = emailField.text , email.isEmail() {
                return TreatMe.client.getInvitation(email).then { invitation -> Bool in
                    self.firstNameField.text = invitation.firstName
                    self.lastNameField.text = invitation.lastName
                    return true
                }.recover { (error: Error) -> Bool in
                    switch error {
                    case ResponseError.notFound:
                        self.setError("No invitation for \(email)")
                    default:
                        self.setError("Unknown error. Please try again")
                    }

                    return false
                }
            } else {
                self.setError("Must specify an email")
                return Promise(value: false)
            }
        case .name:
            if let firstName = firstNameField.text, let lastName = lastNameField.text
                , !firstName.isEmpty && !lastName.isEmpty {
                    return Promise(value: true)
            } else {
                setError("Specify both first and last name")
                return Promise(value: false)
            }
        case .username:
            if let username = usernameField.text , username.isUsername() {
                return TreatMe.client.checkUsername(username).then { available -> Bool in

                    if !available {
                        self.setError("Username not available")
                    }

                    return available
                }
            } else {
                setError("Username must be at least 4 characters and contain only letters and numbers");
                return Promise(value: false)
            }
        case .password:
            if let password = passwordField.text, let confirmPassword = confirmPasswordField.text {
                if !password.isPassword() {
                    setError("Password must be at least 6 characters long")
                    return Promise(value: false)
                } else {
                    if password != confirmPassword {
                        setError("Passwords must match")
                        return Promise(value: false)
                    } else {
                        return Promise(value: true)
                    }
                }
            } else {
                setError("Must specify a password")
                return Promise(value: false)
            }
        }
    }

    func setError(_ error: String) {
        errorLabel.isHidden = false
        errorLabel.text = error
    }

    @IBAction func doNext(_ sender: AnyObject) {
        self.errorLabel.isHidden = true
        let currentStep = orderedSteps[stepsCompleted.count]

        // Vaidate based on current step
        validateStep(currentStep).then { success -> Void in
            if (success) {
                switch currentStep {
                case .password:
                    TreatMe.client.registerUser(self.emailField.text!,
                        firstName: self.firstNameField.text!,
                        lastName: self.lastNameField.text!,
                        username: self.usernameField.text!,
                        password: self.passwordField.text!).then
                    { data -> Void in
                        Flow.goToMain(self)
                    }.catch { error -> Void in
                        switch error {
                        case ResponseError.conflict:
                            self.setError("There is already an account with this email or username")
                        default:
                            self.setError("Registration failed: \(error)")
                        }
                    }
                default:
                    self.stepsCompleted.append(currentStep)
                    self.adjustFormHeight()
                }
            }
        }
    }

    // MARK - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    

}
