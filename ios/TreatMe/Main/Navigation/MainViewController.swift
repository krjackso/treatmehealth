//
//  MainViewController.swift
//  TreatMe
//
//  Created by Keilan Jackson on 3/5/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import UIKit
import DrawerController
import CameraViewController

class MainViewController: DrawerController {

    convenience init() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let main = storyboard.instantiateViewController(withIdentifier: "MainNavController")
        let left = storyboard.instantiateViewController(withIdentifier: "LeftNavController")

        self.init(centerViewController: main, leftDrawerViewController: left, rightDrawerViewController: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.closeDrawerGestureModeMask = .all
    }

}
