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
        self.navigationController?.isNavigationBarHidden = true

        if let username = Auth.instance.username {
            usernameField.text = username
        }

        usernameField.delegate = self
        usernameField.returnKeyType = .next

        passwordField.delegate = self
        passwordField.clearsOnBeginEditing = true
        passwordField.returnKeyType = .done

        signInButton.setTitleColor(UIColor.TMBlue(), for: UIControlState())
        signInButton.setTitleColor(UIColor.TMBlue().withAlphaComponent(0.5), for: .disabled)
        registerButton.setTitleColor(UIColor.TMBlue(), for: UIControlState())
        registerButton.setTitleColor(UIColor.TMBlue().withAlphaComponent(0.5), for: .disabled)

        forgotPasswordButton.setTitleColor(UIColor.TMBlue(), for: UIControlState())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func usernameFieldEditingEnd(_ sender: AnyObject) {
        checkEnableButtons()
    }

    @IBAction func passwordFieldEditingEnd(_ sender: AnyObject) {
        checkEnableButtons()
    }

    func checkEnableButtons() -> Bool {
        if let username = usernameField?.text, let password = passwordField?.text {
            let enableButtons = username.isUsername() && password.isPassword()
            signInButton.isEnabled = enableButtons
        } else {
            signInButton.isEnabled = false
        }
        signInButton.alpha = signInButton.isEnabled ? 1.0 : 0.5
        return signInButton.isEnabled
    }

    @IBAction func doSignIn(_ sender: AnyObject) {
        if let username = usernameField?.text, let password = passwordField?.text {

            usernameField.resignFirstResponder()
            passwordField.resignFirstResponder()

            TreatMe.client.login(username, password: password).then { Void -> Void in
                Drop.upAll()
                Flow.goToMain(self.view.window!)
            }.catch { error -> Void in
                switch error {
                case ResponseError.authenticationError:
                    Drop.down("Looks like an invalid username or password", state: TMState.error)
                default:
                    Drop.down("Sorry, we were unable to sign you in. Please try again in a moment.", state: TMState.warn)
                }
            }

        }
    }

    @IBAction func doForgotPassword(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Forgot Password", message: "Enter your username or email address below and we will email you with instructions for resetting your password", preferredStyle: UIAlertControllerStyle.alert)

        let reset = UIAlertAction(title: "Reset Password", style: .destructive) { (action) in
            let usernameOrEmail = alert.textFields?.first?.text ?? ""

            Drop.down("Give me just one second...", state: TMState.busy)

            TreatMe.client.resetPassword(usernameOrEmail).then { _ -> Void in
                Drop.down("Password reset email successfully sent.  Please check your email and follow the instructions", state: TMState.success, duration: 60)
            }.catch { error in
                switch error {
                case ResponseError.notFound: Drop.down("Password reset failed. Please make sure the username or email is correct", state: TMState.error)
                default: Drop.down("Password reset failed. Please try again", state: TMState.error)
                }
            }

        }

        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)

        alert.addAction(reset)
        alert.addAction(cancel)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Username or email"
        })
        self.present(alert, animated: true, completion: nil)
    }

    // MARK - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField && checkEnableButtons() {
            doSignIn(self)
        }
        return false
    }


}
