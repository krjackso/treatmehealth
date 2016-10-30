//
//  RegisterViewController.swift
//  TreatMe
//
//  Created by Keilan Jackson on 2/27/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import UIKit
import PromiseKit

class RegisterViewController: UIViewController, UITextFieldDelegate {

    lazy var scrollView: UIScrollView = { [unowned self] in
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false

        return scroll
    }()

    lazy var contentView: UIView = { [unowned self] in
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var nextButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: UIControlState())
        button.setTitleColor(UIColor.TMBlue(), for: UIControlState())
        button.setTitleColor(UIColor.TMBlue().withAlphaComponent(0.5), for: .disabled)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)

        button.addTarget(self, action: #selector(self.doRegister), for: .touchUpInside)

        return button
    }()

    lazy var emailLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.text = "Email Address"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 15.0)

        return label
    }()

    lazy var emailField: UITextField = { [unowned self] in
        let field = UITextField()
        field.placeholder = "user@example.com"
        field.minimumFontSize = 17.0
        field.adjustsFontSizeToFitWidth = true
        field.borderStyle = UITextBorderStyle.roundedRect
        field.layer.cornerRadius = 5.0
        field.backgroundColor = UIColor.white
        field.translatesAutoresizingMaskIntoConstraints = false
        field.returnKeyType = .done
        field.keyboardType = UIKeyboardType.emailAddress
        field.autocapitalizationType = .none

        return field
    }()

    lazy var usernameLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.text = "Username"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 15.0)

        return label
        }()

    lazy var usernameField: UITextField = { [unowned self] in
        let field = UITextField()
        field.placeholder = "user"
        field.minimumFontSize = 17.0
        field.adjustsFontSizeToFitWidth = true
        field.borderStyle = UITextBorderStyle.roundedRect
        field.layer.cornerRadius = 5.0
        field.backgroundColor = UIColor.white
        field.translatesAutoresizingMaskIntoConstraints = false
        field.returnKeyType = .done
        field.keyboardType = UIKeyboardType.default
        field.autocapitalizationType = .none

        return field
    }()

    lazy var passwordLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.text = "Password"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 15.0)

        return label
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
        field.returnKeyType = .done
        field.keyboardType = UIKeyboardType.default
        field.autocapitalizationType = .none
        field.isSecureTextEntry = true

        return field
    }()

    lazy var confirmPasswordField: UITextField = { [unowned self] in
        let field = UITextField()
        field.placeholder = "confirm password"
        field.minimumFontSize = 17.0
        field.adjustsFontSizeToFitWidth = true
        field.borderStyle = UITextBorderStyle.roundedRect
        field.layer.cornerRadius = 5.0
        field.backgroundColor = UIColor.white
        field.translatesAutoresizingMaskIntoConstraints = false
        field.returnKeyType = .done
        field.keyboardType = UIKeyboardType.default
        field.autocapitalizationType = .none
        field.isSecureTextEntry = true

        return field
    }()

    lazy var zipLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.text = "ZIP Code"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 15.0)

        return label
    }()

    lazy var zipField: UITextField = { [unowned self] in
        let field = UITextField()
        field.placeholder = "92103"
        field.minimumFontSize = 17.0
        field.adjustsFontSizeToFitWidth = true
        field.borderStyle = UITextBorderStyle.roundedRect
        field.layer.cornerRadius = 5.0
        field.backgroundColor = UIColor.white
        field.translatesAutoresizingMaskIntoConstraints = false
        field.returnKeyType = .done
        field.keyboardType = UIKeyboardType.numbersAndPunctuation
        field.autocapitalizationType = .none

        return field
    }()

    lazy var dobLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.text = "Date of Birth"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 15.0)

        return label
    }()

    lazy var datePicker: UIDatePicker = { [unowned self] in
        let picker = UIDatePicker()
        picker.date = Date()
        picker.maximumDate = Date()
        picker.addTarget(self, action: #selector(self.dateChanged), for: .valueChanged)
        picker.datePickerMode = UIDatePickerMode.date

        return picker
    }()

    lazy var dobField: UITextField = { [unowned self] in
        let field = UITextField()
        field.placeholder = Date().dateFormat()
        field.minimumFontSize = 17.0
        field.adjustsFontSizeToFitWidth = true
        field.borderStyle = UITextBorderStyle.roundedRect
        field.layer.cornerRadius = 5.0
        field.backgroundColor = UIColor.white
        field.translatesAutoresizingMaskIntoConstraints = false

        return field
    }()

    lazy var errorLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.TMRed()
        label.isHidden = true
        label.numberOfLines = 0

        return label
    }()

    var bottomConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        [
            emailField,
            usernameField,
            passwordField,
            confirmPasswordField,
            zipField
        ].forEach { field in
            field.delegate = self
        }

        self.hideKeyboardWhenTapped()

        self.view.backgroundColor = UIColor.offWhite()

        dobField.inputView = datePicker

        [
            emailLabel,
            emailField,
            usernameLabel,
            usernameField,
            passwordLabel,
            passwordField,
            confirmPasswordField,
            zipLabel,
            zipField,
            dobLabel,
            dobField,
            nextButton,
            errorLabel
        ].forEach(self.contentView.addSubview)

        self.scrollView.addSubview(contentView)
        self.view.addSubview(scrollView)

        self.navigationController?.isNavigationBarHidden = false

        bottomConstraint = NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: 0)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.bottomConstraint?.constant = 0.0
            } else {
                self.bottomConstraint?.constant = (endFrame?.size.height ?? 0.0) + 20.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }

    override func updateViewConstraints() {
        self.view.layoutMargins = UIEdgeInsets(top: 20.0, left: 40.0, bottom: 20.0, right: 40.0)

        // Scroll View
        if let bottom = bottomConstraint {
            self.view.addConstraint(bottom)
        }
        self.view.addConstraints([
            NSLayoutConstraint(item: self.view, attribute: .left, relatedBy: .equal, toItem: scrollView, attribute: .left, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: self.view, attribute: .right, relatedBy: .equal, toItem: scrollView, attribute: .right, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: self.view, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 0),
        ])

        // Content View
        self.view.addConstraints([
            NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: .left, relatedBy: .equal, toItem: scrollView, attribute: .left, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: .right, relatedBy: .equal, toItem: scrollView, attribute: .right, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1.0, constant: 0),
        ])

        // Set width of fields
        [emailField, usernameField, passwordField, confirmPasswordField, zipField, dobField].forEach { field in
            let constraint = NSLayoutConstraint(item: field, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 300)
            field.addConstraint(constraint)
        }

        // Email label
        contentView.addConstraints([
            NSLayoutConstraint(item: emailLabel, attribute: .bottom, relatedBy: .equal, toItem: emailField, attribute: .top, multiplier: 1.0, constant: -5),
            NSLayoutConstraint(item: emailLabel, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: emailField, attribute: .left, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: emailField, attribute: .right, relatedBy: .lessThanOrEqual, toItem: emailField, attribute: .right, multiplier: 1.0, constant: 0),
        ])

        // Email field
        contentView.addConstraints([
            NSLayoutConstraint(item: emailField, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: emailField, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: contentView.layoutMargins.top + 40.0),
            NSLayoutConstraint(item: emailField, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .left, multiplier: 1.0, constant: self.view.layoutMargins.left),
            NSLayoutConstraint(item: emailField, attribute: .right, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .right, multiplier: 1.0, constant: -1 * self.view.layoutMargins
                .right),
        ])

        // Username label
        contentView.addConstraints([
            NSLayoutConstraint(item: usernameLabel, attribute: .bottom, relatedBy: .equal, toItem: usernameField, attribute: .top, multiplier: 1.0, constant: -5),
            NSLayoutConstraint(item: usernameLabel, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: usernameField, attribute: .left, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: usernameLabel, attribute: .right, relatedBy: .lessThanOrEqual, toItem: usernameField, attribute: .right, multiplier: 1.0, constant: 0),
        ])

        // Username field
        contentView.addConstraints([
            NSLayoutConstraint(item: usernameField, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: usernameField, attribute: .top, relatedBy: .equal, toItem: emailField, attribute: .bottom, multiplier: 1.0, constant: 40),
            NSLayoutConstraint(item: usernameField, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .left, multiplier: 1.0, constant: self.view.layoutMargins.left),
            NSLayoutConstraint(item: usernameField, attribute: .right, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .right, multiplier: 1.0, constant: -1 * self.view.layoutMargins
                .right),
        ])

        // Password label
        contentView.addConstraints([
            NSLayoutConstraint(item: passwordLabel, attribute: .bottom, relatedBy: .equal, toItem: passwordField, attribute: .top, multiplier: 1.0, constant: -5),
            NSLayoutConstraint(item: passwordLabel, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: passwordField, attribute: .left, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: passwordLabel, attribute: .right, relatedBy: .lessThanOrEqual, toItem: passwordField, attribute: .right, multiplier: 1.0, constant: 0),
        ])

        // Password field
        contentView.addConstraints([
            NSLayoutConstraint(item: passwordField, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: passwordField, attribute: .top, relatedBy: .equal, toItem: usernameField, attribute: .bottom, multiplier: 1.0, constant: 40),
            NSLayoutConstraint(item: passwordField, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .left, multiplier: 1.0, constant: self.view.layoutMargins.left),
            NSLayoutConstraint(item: passwordField, attribute: .right, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .right, multiplier: 1.0, constant: -1 * self.view.layoutMargins
                .right),
        ])

        // Confirm Password field
        contentView.addConstraints([
            NSLayoutConstraint(item: confirmPasswordField, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: confirmPasswordField, attribute: .top, relatedBy: .equal, toItem: passwordField, attribute: .bottom, multiplier: 1.0, constant: 10),
            NSLayoutConstraint(item: confirmPasswordField, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .left, multiplier: 1.0, constant: self.view.layoutMargins.left),
            NSLayoutConstraint(item: confirmPasswordField, attribute: .right, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .right, multiplier: 1.0, constant: -1 * self.view.layoutMargins
                .right),
        ])

        // Zip label
        contentView.addConstraints([
            NSLayoutConstraint(item: zipLabel, attribute: .bottom, relatedBy: .equal, toItem: zipField, attribute: .top, multiplier: 1.0, constant: -5),
            NSLayoutConstraint(item: zipLabel, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: zipField, attribute: .left, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: zipLabel, attribute: .right, relatedBy: .lessThanOrEqual, toItem: zipField, attribute: .right, multiplier: 1.0, constant: 0),
        ])

        // Zip field
        contentView.addConstraints([
            NSLayoutConstraint(item: zipField, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: zipField, attribute: .top, relatedBy: .equal, toItem: confirmPasswordField, attribute: .bottom, multiplier: 1.0, constant: 40),
            NSLayoutConstraint(item: zipField, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .left, multiplier: 1.0, constant: self.view.layoutMargins.left),
            NSLayoutConstraint(item: zipField, attribute: .right, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .right, multiplier: 1.0, constant: -1 * self.view.layoutMargins
                .right),
        ])

        // Dob label
        contentView.addConstraints([
            NSLayoutConstraint(item: dobLabel, attribute: .bottom, relatedBy: .equal, toItem: dobField, attribute: .top, multiplier: 1.0, constant: -5),
            NSLayoutConstraint(item: dobLabel, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: dobField, attribute: .left, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: dobLabel, attribute: .right, relatedBy: .lessThanOrEqual, toItem: dobField, attribute: .right, multiplier: 1.0, constant: 0),
        ])

        // Dob field
        contentView.addConstraints([
            NSLayoutConstraint(item: dobField, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: dobField, attribute: .top, relatedBy: .equal, toItem: zipField, attribute: .bottom, multiplier: 1.0, constant: 40),
            NSLayoutConstraint(item: dobField, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .left, multiplier: 1.0, constant: self.view.layoutMargins.left),
            NSLayoutConstraint(item: dobField, attribute: .right, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .right, multiplier: 1.0, constant: -1 * self.view.layoutMargins
                .right),
        ])

        // Next button
        contentView.addConstraints([
            NSLayoutConstraint(item: nextButton, attribute: .top, relatedBy: .equal, toItem: dobField, attribute: .bottom, multiplier: 1.0, constant: 20),
            NSLayoutConstraint(item: nextButton, attribute: .right, relatedBy: .equal, toItem: dobField, attribute: .right, multiplier: 1.0, constant: 0),
        ])

        // Error label
        contentView.addConstraints([
            NSLayoutConstraint(item: errorLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: errorLabel, attribute: .top, relatedBy: .equal, toItem: nextButton, attribute: .bottom, multiplier: 1.0, constant: 20),
            NSLayoutConstraint(item: errorLabel, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .left, multiplier: 1.0, constant: self.view.layoutMargins.left),
            NSLayoutConstraint(item: errorLabel, attribute: .right, relatedBy: .lessThanOrEqual, toItem: contentView, attribute: .right, multiplier: 1.0, constant: -1 * self.view.layoutMargins
                .right),
            NSLayoutConstraint(item: errorLabel, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: -1 * self.view.layoutMargins.bottom),
        ])

        super.updateViewConstraints()
    }

    func validate() -> Bool {
        guard let email = emailField.text, email.isEmail() else {
            self.setError("Must specify an email")
            return false
        }

        guard let username = usernameField.text, username.isUsername() else {
            setError("Username must be at least 4 characters and contain only letters and numbers");
            return false
        }

        if let password = passwordField.text, let confirmPassword = confirmPasswordField.text {
            if !password.isPassword() {
                setError("Password must be at least 6 characters long")
                return false
            } else if password != confirmPassword {
                setError("Passwords must match")
                return false
            }
        } else {
            setError("Must specify a password")
            return false
        }
        return true
    }

    func setError(_ error: String) {
        errorLabel.isHidden = false
        errorLabel.text = error
    }

    func doRegister(_ sender: AnyObject) {
        self.errorLabel.isHidden = true

        // Vaidate based on current step
        if (validate()) {
            TreatMe.client.registerUser(
                username: self.usernameField.text!,
                email: self.emailField.text!,
                dob: self.dobField.text!,
                zip: self.zipField.text!,
                password: self.passwordField.text!).then
                { data -> Void in
                    Flow.goToMain(self)
                }.catch { error -> Void in
                    switch error {
                    case ResponseError.conflict:
                        self.setError("There is already an account with this email or username")
                    case TreatMeError.apiError(let reason):
                        self.setError(reason)
                    default:
                        self.setError("Registration failed: \(error)")
                    }
            }
        }

    }

    // MARK - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    // MARK - UIDatePickerDelegate
    func dateChanged(_ datePicker: UIDatePicker) -> Void {
        self.dobField.text = datePicker.date.dateFormat()
    }

}
