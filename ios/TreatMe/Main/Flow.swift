//
//  Flow.swift
//  TreatMe
//
//  Created by Keilan Jackson on 3/4/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import Foundation
import UIKit
import Swiftz
import PromiseKit
import SwiftyDrop

let appNotificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)

public class Flow {


    public static func goToLogin(source: UIViewController) { goToLogin(Either.Left(source)) }
    public static func goToLogin(source: UIWindow) { goToLogin(Either.Right(source)) }
    public static func goToLogin(source: Either<UIViewController, UIWindow>) {
        let storyboard = UIStoryboard(name: "SignIn", bundle: nil)

        if let signIn = storyboard.instantiateInitialViewController() {
            presentController(signIn, fromSource: source)
        }
    }

    public static func goToMain(source: UIViewController) { goToMain(Either.Left(source)) }
    public static func goToMain(source: UIWindow) { goToMain(Either.Right(source)) }
    public static func goToMain(source: Either<UIViewController, UIWindow>) {
        // Get the authenticated user, groups, and channels
        when(TreatMe.client.refreshGroups(), TreatMe.client.refreshUserChannels())
        .onError { error in
            debugPrint("Error initializing main: \(error)")

            // Clear Auth to get a clean login
            Auth.instance.clear()

            // Show something to the user
            Drop.down("Something went wrong when loading your data. Please login again.", state: TMState.Error, duration: 180)
            Flow.goToLogin(source)
        }
        .then { _ -> Void in

            if let selectedChannel = TreatMe.data.selectedChannelId, _ = TreatMe.data.channels[selectedChannel] {
                // A real channel is selected
            } else {
                // Select the first channel in the first group
                if let group = TreatMe.data.groups.first,
                    let channel = (TreatMe.data.groupChannels[group] ?? []).first {
                    TreatMe.data.selectedChannelId = channel.id
                }
            }

            let main = MainViewController()
            presentController(main, fromSource: source)

            // Connect to pusher
            PusherClient.instance.start()
        }

        UIApplication.sharedApplication().registerUserNotificationSettings(appNotificationSettings)

    }

    public static func presentController(controller: UIViewController, fromSource source: Either<UIViewController, UIWindow>) {
        source.either(
            onLeft: { sourceController -> Void in
                sourceController.presentViewController(controller, animated: true, completion: nil)
            },
            onRight: { window -> Void in
                window.rootViewController = controller
            }
        )
    }

    

}