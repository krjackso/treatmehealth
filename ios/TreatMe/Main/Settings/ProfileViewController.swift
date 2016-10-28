//
//  ProfileViewController.swift
//  TreatMe
//
//  Created by Keilan Jackson on 4/3/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import UIKit
import CameraViewController
import Kingfisher
import SwiftyDrop
import HockeySDK

class ProfileViewController: UIViewController {

    lazy var camera: CameraViewController = { [unowned self] in
        let completion: CameraViewCompletion = { (image, _) in
            self.cameraCompleted(image)
        }
        return CameraViewController(croppingEnabled: true, allowsLibraryAccess: true, completion: completion)
    }()

    let closeImage = UIImage(named: "close-x-icon")!

    lazy var closeButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.setImage(self.closeImage, for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false

        button.addTarget(self, action: #selector(self.closeButtonPress), for: .touchUpInside)

        return button
    }()

    lazy var uploadButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        button.setTitle("Upload Photo", for: UIControlState())
        button.setTitleColor(UIColor.TMBlue(), for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        button.layer.cornerRadius = 5.0
        button.layer.borderColor = UIColor.TMBlue().cgColor
        button.layer.borderWidth = 1.0
        button.addTarget(self, action: #selector(self.uploadButtonPress), for: .touchUpInside)
        return button
    }()

    lazy var profileImageView: UIImageView = { [unowned self] in
        let imageView = UIImageView()

        imageView.tintColor = UIColor.white
        imageView.backgroundColor = UserProfileImage.colorForUser(self.user)

        imageView.setImageForUser(self.user).catch { _ -> Void in
            imageView.image = UserProfileImage.defaultImage()
        }

        imageView.layer.cornerRadius = 5.0
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        imageView.addConstraints([
            NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: imageView, attribute: .height, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 100)
        ])

        return imageView
    }()

    lazy var logoutButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: UIControlState())
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.backgroundColor = UIColor.TMRed()
        button.layer.cornerRadius = 5.0
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)

        button.addTarget(self, action: #selector(self.logoutButtonPress), for: .touchUpInside)

        return button
    }()

    lazy var usernameLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.text = "@\(self.user.username)"
        label.font = UIFont.systemFont(ofSize: 17.0)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 15.0/17
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    lazy var realnameLabel: UILabel = { [unowned self] in
        let label = UILabel()
        if let first = self.user.firstName, let last = self.user.lastName {
            label.text = "\(first) \(last)"
        } else {
            label.frame.size = CGSize.zero
        }
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 17.0/23
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    lazy var settingsButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        button.setTitle("Go to Settings", for: UIControlState())
        button.setTitleColor(UIColor.TMBlue(), for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        button.layer.cornerRadius = 5.0
        button.layer.borderColor = UIColor.TMBlue().cgColor
        button.layer.borderWidth = 1.0
        button.addTarget(self, action: #selector(self.settingsButtonPress), for: .touchUpInside)
        return button
    }()

    lazy var feedbackButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        button.setTitle("Feedback", for: UIControlState())
        button.setTitleColor(UIColor.TMBlue(), for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        button.layer.cornerRadius = 5.0
        button.layer.borderColor = UIColor.TMBlue().cgColor
        button.layer.borderWidth = 1.0
        button.addTarget(self, action: #selector(self.feedbackButtonPress), for: .touchUpInside)
        return button
    }()

    fileprivate let user: User

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.offWhite()

        [
            realnameLabel,
            usernameLabel,
            profileImageView,
            closeButton,
            uploadButton,
            settingsButton,
            feedbackButton,
            logoutButton
        ].forEach(self.view.addSubview)
    }

    override func updateViewConstraints() {
        self.view.layoutMargins = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 0, right: 0.0)

        // Button widths
        [uploadButton, settingsButton, feedbackButton, logoutButton].forEach { button in
            self.view.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 140))
        }

        // closeButton
        self.view.addConstraints([
            NSLayoutConstraint(item: closeButton, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: self.view.layoutMargins.left),
            NSLayoutConstraint(item: closeButton, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: self.view.layoutMargins.top)
        ])

        // realnameLabel
        self.view.addConstraints([
            NSLayoutConstraint(item: realnameLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: realnameLabel, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: self.view.layoutMargins.top + 40),
            NSLayoutConstraint(item: realnameLabel, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 10),
            NSLayoutConstraint(item: realnameLabel, attribute: .right, relatedBy: .lessThanOrEqual, toItem: self.view, attribute: .right, multiplier: 1.0, constant: -10),
        ])

        // usernameLabel
        self.view.addConstraints([
            NSLayoutConstraint(item: usernameLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: usernameLabel, attribute: .top, relatedBy: .equal, toItem: self.realnameLabel, attribute: .bottom, multiplier: 1.0, constant: 10),
            NSLayoutConstraint(item: usernameLabel, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 10),
            NSLayoutConstraint(item: usernameLabel, attribute: .right, relatedBy: .lessThanOrEqual, toItem: self.view, attribute: .right, multiplier: 1.0, constant: -10),
        ])

        // profileImageView
        self.view.addConstraints([
            NSLayoutConstraint(item: profileImageView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: profileImageView, attribute: .top, relatedBy: .equal, toItem: self.usernameLabel, attribute: .bottom, multiplier: 1.0, constant: 10),
        ])

        // uploadButton
        self.view.addConstraints([
            NSLayoutConstraint(item: uploadButton, attribute: .top, relatedBy: .equal, toItem: profileImageView, attribute: .bottom, multiplier: 1.0, constant: 10.0),
            NSLayoutConstraint(item: uploadButton, attribute: .centerX, relatedBy: .equal, toItem: profileImageView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        ])

        // settingsButton
        self.view.addConstraints([
            NSLayoutConstraint(item: settingsButton, attribute: .top, relatedBy: .equal, toItem: uploadButton, attribute: .bottom, multiplier: 1.0, constant: 20.0),
            NSLayoutConstraint(item: settingsButton, attribute: .centerX, relatedBy: .equal, toItem: profileImageView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
            ])

        // feedbackButton
        self.view.addConstraints([
            NSLayoutConstraint(item: feedbackButton, attribute: .top, relatedBy: .equal, toItem: settingsButton, attribute: .bottom, multiplier: 1.0, constant: 20.0),
            NSLayoutConstraint(item: feedbackButton, attribute: .centerX, relatedBy: .equal, toItem: profileImageView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
            ])

        // logoutButton
        self.view.addConstraints([
            NSLayoutConstraint(item: logoutButton, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -20.0),
            NSLayoutConstraint(item: logoutButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0)
        ])

        super.updateViewConstraints()
    }

    func closeButtonPress() {
        self.dismiss(animated: true, completion: nil)
    }

    func uploadButtonPress() {
        self.present(camera, animated: true, completion: nil)
    }

    func logoutButtonPress() {
        TreatMe.client.logout().always { _ in
            TreatMe.resetData()
            PusherClient.instance.stop()
            Auth.instance.clear()
            Flow.goToLogin(self)
        }
    }

    func settingsButtonPress() {
        UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!);
    }

    func feedbackButtonPress() {
        BITHockeyManager.shared().feedbackManager.showFeedbackListView()
    }

    func cameraCompleted(_ image: UIImage?) {
        if let image = image {
            Drop.down("Uploading image...", state:.blur(.dark), duration: 30.0, action: nil)

            TreatMe.client.uploadProfilePicture(image).then { imageUrl -> Void in
                self.profileImageView.setImageWithUrlString(imageUrl)
                Drop.down("Successfully updated profile image!", state: TMState.success)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: TreatMeNotifications.RefreshUserImage.rawValue), object: self)
            }.catch { error in
                Drop.down("Failed to change profile image. Please try again!", state: TMState.error)
            }

        }
        self.camera.dismiss(animated: true, completion: nil)
        self.updateViewConstraints()
    }

}
