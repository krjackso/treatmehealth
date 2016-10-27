//
//  LoginController.swift
//  TreatMe
//
//  Created by Keilan Jackson on 2/27/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import UIKit
import SwiftyDrop

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        checkEnableButtons()
        self.navigationController?.navigationBarHidden = true

        if let username = Auth.instance.username {
            usernameField.text = username
        }

        usernameField.delegate = self
        usernameField.returnKeyType = .Next

        passwordField.delegate = self
        passwordField.clearsOnBeginEditing = true
        passwordField.returnKeyType = .Done

        signInButton.setTitleColor(UIColor.TMBlue(), forState: .Normal)
        signInButton.setTitleColor(UIColor.TMBlue().colorWithAlphaComponent(0.5), forState: .Disabled)
        registerButton.setTitleColor(UIColor.TMBlue(), forState: .Normal)
        registerButton.setTitleColor(UIColor.TMBlue().colorWithAlphaComponent(0.5), forState: .Disabled)

        forgotPasswordButton.setTitleColor(UIColor.TMBlue(), forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func usernameFieldEditingEnd(sender: AnyObject) {
        checkEnableButtons()
    }

    @IBAction func passwordFieldEditingEnd(sender: AnyObject) {
        checkEnableButtons()
    }

    func checkEnableButtons() -> Bool {
        if let username = usernameField?.text, password = passwordField?.text {
            let enableButtons = username.isUsername() && password.isPassword()
            signInButton.enabled = enableButtons
        } else {
            signInButton.enabled = false
        }
        signInButton.alpha = signInButton.enabled ? 1.0 : 0.5
        return signInButton.enabled
    }

    @IBAction func doSignIn(sender: AnyObject) {
        if let username = usernameField?.text, password = passwordField?.text {

            usernameField.resignFirstResponder()
            passwordField.resignFirstResponder()

            TreatMe.client.login(username, password: password).then { Void -> Void in
                Drop.upAll()
                Flow.goToMain(self.view.window!)
            }.error { error -> Void in
                switch error {
                case ResponseError.AuthenticationError:
                    Drop.down("Looks like an invalid username or password", state: TMState.Error)
                default:
                    Drop.down("Sorry, we were unable to sign you in. Please try again in a moment.", state: TMState.Warn)
                }
            }

        }
    }

    @IBAction func doForgotPassword(sender: AnyObject) {
        let alert = UIAlertController(title: "Forgot Password", message: "Enter your username or email address below and we will email you with instructions for resetting your password", preferredStyle: UIAlertControllerStyle.Alert)

        let reset = UIAlertAction(title: "Reset Password", style: .Destructive) { (action) in
            let usernameOrEmail = alert.textFields?.first?.text ?? ""

            Drop.down("Give me just one second...", state: TMState.Busy)

            TreatMe.client.resetPassword(usernameOrEmail).then { _ -> Void in
                Drop.down("Password reset email successfully sent.  Please check your email and follow the instructions", state: TMState.Success, duration: 60)
            }.error { error in
                switch error {
                case ResponseError.NotFound: Drop.down("Password reset failed. Please make sure the username or email is correct", state: TMState.Error)
                default: Drop.down("Password reset failed. Please try again", state: TMState.Error)
                }
            }

        }

        let cancel = UIAlertAction(title: "Cancel", style: .Default, handler: nil)

        alert.addAction(reset)
        alert.addAction(cancel)
        alert.addTextFieldWithConfigurationHandler({ textField in
            textField.placeholder = "Username or email"
        })
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField && checkEnableButtons() {
            doSignIn(self)
        }
        return false
    }


}