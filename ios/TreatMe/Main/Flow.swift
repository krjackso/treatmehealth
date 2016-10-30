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

let appNotificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)

open class Flow {


    open static func goToLogin(_ source: UIViewController) { goToLogin(Either.Left(source)) }
    open static func goToLogin(_ source: UIWindow) { goToLogin(Either.Right(source)) }
    open static func goToLogin(_ source: Either<UIViewController, UIWindow>) {
        let signIn = SignInViewController()
        presentController(signIn, fromSource: source)
    }

    open static func goToMain(_ source: UIViewController) { goToMain(Either.Left(source)) }
    open static func goToMain(_ source: UIWindow) { goToMain(Either.Right(source)) }
    open static func goToMain(_ source: Either<UIViewController, UIWindow>) {
        // Get the authenticated user, groups, and channels
        when(fulfilled: TreatMe.client.refreshGroups(), TreatMe.client.refreshUserChannels())
        .onError { error in
            debugPrint("Error initializing main: \(error)")

            // Clear Auth to get a clean login
            Auth.instance.clear()

            // Show something to the user
            Drop.down("Something went wrong when loading your data. Please login again.", state: TMState.error, duration: 180)
        }
        .then { _ -> Void in

            if let selectedChannel = TreatMe.data.selectedChannelId, let _ = TreatMe.data.channels[selectedChannel] {
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

        UIApplication.shared.registerUserNotificationSettings(appNotificationSettings)

    }

    open static func presentController(_ controller: UIViewController, fromSource source: Either<UIViewController, UIWindow>) {
        source.either(
            onLeft: { sourceController -> Void in
                sourceController.present(controller, animated: true, completion: nil)
            },
            onRight: { window -> Void in
                window.rootViewController = controller
            }
        )
    }

    

}
