//
//  AppDelegate.swift
//  TreatMe
//
//  Created by Keilan Jackson on 2/27/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import UIKit
import Reachability
import PromiseKit
import SwiftyDrop
import HockeySDK

enum InitializeError: ErrorType {
    case NoWindow
}

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate, BITHockeyManagerDelegate {

    var window: UIWindow?

    var reachability: Reachability?

    var secondsLeft = 0

    func getReachability() -> Reachability? {
        let reachability = try? Reachability.reachabilityForInternetConnection()
        reachability?.whenReachable = { reachability in
            TreatMe.client.checkAuth().then { authorized -> Void in
                if authorized {
                    PusherClient.instance.start()
                }
            }
        }
        reachability?.whenUnreachable = { reachability in
            Drop.down("Network unreachable", state: TMState.Warn)
            PusherClient.instance.stop()
        }
        return reachability
    }

    func attemptInitialize() -> Promise<Void> {
        guard let window = self.window else {
            return Promise(error: InitializeError.NoWindow)
        }

        return TreatMe.client.checkAuth().then { authorized -> Void in
            if authorized {
                Flow.goToMain(window)
            } else {
                Flow.goToLogin(window)
            }
        }.asVoid()
    }

    func updateInitializeStatus() -> Void {
        Drop.down("Failed to initialize. Will try again in \(secondsLeft)s", state: TMState.Error, duration: 2)
        self.secondsLeft -= 1
    }

    func initializeRecursive() -> Void {
        attemptInitialize().onError { _ in
            self.secondsLeft = 30

            let timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self.updateInitializeStatus), userInfo: nil, repeats: true)

            delay(30) {
                timer.invalidate()
                self.initializeRecursive()
            }

        }.then { _ -> Void in
            Drop.upAll()
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        UINavigationBar.appearance().tintColor = UIColor.TMBlue()

        reachability = getReachability()

        setupHockeyApp()

        initializeRecursive()

        return true
    }

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {

        if notificationSettings != .None {
            application.registerForRemoteNotifications()
        } else {
            application.unregisterForRemoteNotifications()
        }
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tokenString = deviceToken.toHexString()
        debugPrint("Registered with device token \(tokenString)")

        TreatMe.client.updateDeviceToken(tokenString)
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        debugPrint("Failed to register for remote notifications \(error)")
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

        // If the application is running, update the badge.  Otherwise the system will do it
        if let badge = userInfo["aps"]?["badge"] as? Int where application.applicationState == .Active {
            print("Setting badge to \(badge)")
            application.applicationIconBadgeNumber = badge
        }

        let result = handleMessage(userInfo)
        completionHandler(result)
    }

    func handleMessage(userInfo: [NSObject : AnyObject]) -> UIBackgroundFetchResult {
        if let message = try? Message.decode(userInfo), let channel = TreatMe.data.channels[message.channelId] {
            print("Received \(message)")
            TreatMe.data.insertMessage(message, forChannel: channel, notify: true)
            return .NewData
        }
        return .NoData
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        PusherClient.instance.stop()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        PusherClient.instance.start()
        NSNotificationCenter.defaultCenter().postNotificationName(TreatMeNotifications.RefreshChat.rawValue, object: self)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK - HockeyApp
    func setupHockeyApp() {
        BITHockeyManager.sharedHockeyManager().configureWithIdentifier("aa04e2beee6f43a9a3d1a1eaf29277b6")
        BITHockeyManager.sharedHockeyManager().startManager()
        BITHockeyManager.sharedHockeyManager().authenticator.authenticateInstallation()
        BITHockeyManager.sharedHockeyManager().feedbackManager.showAlertOnIncomingMessages = true
    }

    func userIDForHockeyManager(hockeyManager: BITHockeyManager!, componentManager: BITHockeyBaseManager!) -> String! {
        return Auth.instance.userHref ?? "Unauthenticated"
    }

}

