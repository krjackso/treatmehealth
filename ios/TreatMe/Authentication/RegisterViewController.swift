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
    case Email
    case Name
    case Username
    case Password
}

class RegisterViewController: UIViewController, UITextFieldDelegate {

    var stepsCompleted: [RegistrationStep] = []
    let orderedSteps: [RegistrationStep] = [.Email, .Name, .Username, .Password]

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
            field.delegate = self
            field.returnKeyType = .Done
        }

        nextButton.setTitleColor(UIColor.TMBlue(), forState: .Normal)
        nextButton.setTitleColor(UIColor.TMBlue().colorWithAlphaComponent(0.5), forState: .Disabled)
        errorLabel.textColor = UIColor.TMRed()

        errorLabel.hidden = true
        self.navigationController?.navigationBarHidden = false
        adjustFormHeight()
    }

    func adjustFormHeight() {
        if let bottom = formBottomConstraint {
            formView.removeConstraint(bottom)
        }

        if stepsCompleted.contains(.Password) {

        } else if stepsCompleted.contains(.Username) {
            formBottomConstraint = NSLayoutConstraint(item: formView, attribute: .Bottom, relatedBy: .GreaterThanOrEqual, toItem: confirmPasswordField, attribute: .Bottom, multiplier: 1.0, constant: formViewPadding)
        } else if stepsCompleted.contains(.Name) {
            formBottomConstraint = NSLayoutConstraint(item: formView, attribute: .Bottom, relatedBy: .GreaterThanOrEqual, toItem: usernameField, attribute: .Bottom, multiplier: 1.0, constant: formViewPadding)
        } else if stepsCompleted.contains(.Email) {
            formBottomConstraint = NSLayoutConstraint(item: formView, attribute: .Bottom, relatedBy: .GreaterThanOrEqual, toItem: firstNameField, attribute: .Bottom, multiplier: 1.0, constant: formViewPadding)
        } else {
            formBottomConstraint = NSLayoutConstraint(item: formView, attribute: .Bottom, relatedBy: .GreaterThanOrEqual, toItem: emailField, attribute: .Bottom, multiplier: 1.0, constant: formViewPadding)
        }

        if let bottom = formBottomConstraint {
            formView.addConstraint(bottom)
        }

        if !stepsCompleted.isEmpty {
            UIView.animateWithDuration(0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }

    func validateStep(step: RegistrationStep) -> Promise<Bool> {
        switch step {
        case .Email:
            if let email = emailField.text where email.isEmail() {
                return TreatMe.client.getInvitation(email).then { invitation -> Bool in
                    self.firstNameField.text = invitation.firstName
                    self.lastNameField.text = invitation.lastName
                    return true
                }.recover { (error: ErrorType) -> Bool in
                    switch error {
                    case ResponseError.NotFound:
                        self.setError("No invitation for \(email)")
                    default:
                        self.setError("Unknown error. Please try again")
                    }

                    return false
                }
            } else {
                self.setError("Must specify an email")
                return Promise(false)
            }
        case .Name:
            if let firstName = firstNameField.text, lastName = lastNameField.text
                where !firstName.isEmpty && !lastName.isEmpty {
                    return Promise(true)
            } else {
                setError("Specify both first and last name")
                return Promise(false)
            }
        case .Username:
            if let username = usernameField.text where username.isUsername() {
                return TreatMe.client.checkUsername(username).then { available -> Bool in

                    if !available {
                        self.setError("Username not available")
                    }

                    return available
                }
            } else {
                setError("Username must be at least 4 characters and contain only letters and numbers");
                return Promise(false)
            }
        case .Password:
            if let password = passwordField.text, confirmPassword = confirmPasswordField.text {
                if !password.isPassword() {
                    setError("Password must be at least 6 characters long")
                    return Promise(false)
                } else {
                    if password != confirmPassword {
                        setError("Passwords must match")
                        return Promise(false)
                    } else {
                        return Promise(true)
                    }
                }
            } else {
                setError("Must specify a password")
                return Promise(false)
            }
        }
    }

    func setError(error: String) {
        errorLabel.hidden = false
        errorLabel.text = error
    }

    @IBAction func doNext(sender: AnyObject) {
        self.errorLabel.hidden = true
        let currentStep = orderedSteps[stepsCompleted.count]

        // Vaidate based on current step
        validateStep(currentStep).then { success -> Void in
            if (success) {
                switch currentStep {
                case .Password:
                    TreatMe.client.registerUser(self.emailField.text!,
                        firstName: self.firstNameField.text!,
                        lastName: self.lastNameField.text!,
                        username: self.usernameField.text!,
                        password: self.passwordField.text!).then
                    { data -> Void in
                        Flow.goToMain(self)
                    }.error { error -> Void in
                        switch error {
                        case ResponseError.Conflict:
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
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    

}
