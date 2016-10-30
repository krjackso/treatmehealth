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

    lazy var treatMeLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.text = "TreatMe Health"
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 21.0)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    lazy var usernameField: UITextField = { [unowned self] in
        let field = UITextField()
        field.placeholder = "username"
        field.minimumFontSize = 17.0
        field.adjustsFontSizeToFitWidth = true
        field.borderStyle = UITextBorderStyle.roundedRect
        field.layer.cornerRadius = 5.0
        field.backgroundColor = UIColor.white
        field.translatesAutoresizingMaskIntoConstraints = false
        field.returnKeyType = .next
        field.keyboardType = UIKeyboardType.default
        field.autocapitalizationType = .none

        if let username = Auth.instance.username {
            field.text = username
        }

        return field
    }()

    lazy var passwordField: UITextField = { [unowned self] in
        let field = UITextField()
        field.placeholder = "password"
        field.minimumFontSize = 17.0
        field.adjustsFontSizeToFitWidth = true
        field.borderStyle = UITextBorderStyle.roundedRect
        field.layer.cornerRadius = 5.0
        field.backgroundColor = UIColor.white
        field.translatesAutoresizingMaskIntoConstraints = false
        field.clearsOnBeginEditing = true
        field.returnKeyType = .done
        field.keyboardType = UIKeyboardType.default
        field.autocapitalizationType = .none
        field.isSecureTextEntry = true
        
        return field
    }()

    lazy var signInButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.setTitleColor(UIColor.TMBlue(), for: .normal)
        button.setTitleColor(UIColor.TMBlue().withAlphaComponent(0.5), for: .disabled)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.addTarget(self, action: #selector(self.doSignIn), for: .touchUpInside)

        return button
    }()

    lazy var registerButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(UIColor.TMBlue(), for: .normal)
        button.setTitleColor(UIColor.TMBlue().withAlphaComponent(0.5), for: .disabled)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.addTarget(self, action: #selector(self.doRegister), for: .touchUpInside)

        return button
    }()

    lazy var forgotPasswordButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.setTitle("Forgot your password?", for: .normal)
        button.setTitleColor(UIColor.TMBlue(), for: .normal)
        button.setTitleColor(UIColor.TMBlue().withAlphaComponent(0.5), for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 11.0)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.addTarget(self, action: #selector(self.doForgotPassword), for: .touchUpInside)

        return button
    }()

    lazy var contentView: UIView = { [unowned self] in
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        checkEnableButtons()

        usernameField.delegate = self
        passwordField.delegate = self

        [
            usernameField,
            passwordField,
            signInButton,
            registerButton
        ].forEach(contentView.addSubview)

        self.view.addSubview(treatMeLabel)
        self.view.addSubview(contentView)
        self.view.addSubview(forgotPasswordButton)

        self.view.backgroundColor = UIColor.offWhite()
    }

    override func updateViewConstraints() {
        self.view.layoutMargins = UIEdgeInsets(top: 40.0, left: 40.0, bottom: 20.0, right: 40.0)

        // TreatMe Label
        self.view.addConstraints([
            NSLayoutConstraint(item: treatMeLabel, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: self.view.layoutMargins.top),
            NSLayoutConstraint(item: treatMeLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0),
        ])

        // Content View
        self.view.addConstraints([
            NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: self.view.layoutMargins.left),
            NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: -1 * self.view.layoutMargins.right),
        ])

        // Forgot password
        self.view.addConstraints([
            NSLayoutConstraint(item: forgotPasswordButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: forgotPasswordButton, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: self.view.layoutMargins.left),
            NSLayoutConstraint(item: forgotPasswordButton, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: -1 * self.view.layoutMargins.right),
            NSLayoutConstraint(item: forgotPasswordButton, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -1 * self.view.layoutMargins.bottom),
        ])

        // Username field
        contentView.addConstraints([
            NSLayoutConstraint(item: passwordField, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: usernameField, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: usernameField, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: 0),
        ])

        // Password field
        contentView.addConstraints([
            NSLayoutConstraint(item: passwordField, attribute: .top, relatedBy: .equal, toItem: usernameField, attribute: .bottom, multiplier: 1.0, constant: 20),
            NSLayoutConstraint(item: passwordField, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: passwordField, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: 0),
        ])

        // Register button
        contentView.addConstraints([
            NSLayoutConstraint(item: registerButton, attribute: .top, relatedBy: .equal, toItem: passwordField, attribute: .bottom, multiplier: 1.0, constant: 20),
            NSLayoutConstraint(item: registerButton, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: registerButton, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: -10),
            NSLayoutConstraint(item: registerButton, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0),
        ])

        // Sign In button
        contentView.addConstraints([
            NSLayoutConstraint(item: signInButton, attribute: .top, relatedBy: .equal, toItem: passwordField, attribute: .bottom, multiplier: 1.0, constant: 20),
            NSLayoutConstraint(item: signInButton, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 10),
            NSLayoutConstraint(item: signInButton, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: signInButton, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0),
        ])

        super.updateViewConstraints()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        checkEnableButtons()
    }

    func checkEnableButtons() -> Bool {
        if let username = usernameField.text, let password = passwordField.text {
            let enableButtons = username.isUsername() && password.isPassword()
            signInButton.isEnabled = enableButtons
        } else {
            signInButton.isEnabled = false
        }
        signInButton.alpha = signInButton.isEnabled ? 1.0 : 0.5
        return signInButton.isEnabled
    }

    func doSignIn(_ sender: AnyObject) {
        if let username = usernameField.text, let password = passwordField.text {

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

    func doRegister(_ sender: AnyObject) {
        let register = RegisterViewController()
        self.present(register, animated: true, completion: nil)
    }

    func doForgotPassword(_ sender: AnyObject) {
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
