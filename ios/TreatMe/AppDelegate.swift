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

enum InitializeError: Error {
    case noWindow
}

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate, BITHockeyManagerDelegate {

    var window: UIWindow?

    var reachability: Reachability?

    var secondsLeft = 0

    func getReachability() -> Reachability? {
        let reachability = Reachability()
        reachability?.whenReachable = { reachability in
            TreatMe.client.checkAuth().then { authorized -> Void in
                if authorized {
                    PusherClient.instance.start()
                }
            }
        }
        reachability?.whenUnreachable = { reachability in
            Drop.down("Network unreachable", state: TMState.warn)
            PusherClient.instance.stop()
        }
        return reachability
    }

    func attemptInitialize() -> Promise<Void> {
        guard let window = self.window else {
            return Promise(error: InitializeError.noWindow)
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
        Drop.down("Failed to initialize. Will try again in \(secondsLeft)s", state: TMState.error, duration: 2)
        self.secondsLeft -= 1
    }

    func initializeRecursive() -> Void {
        attemptInitialize().onError { _ in
            self.secondsLeft = 30

            let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateInitializeStatus), userInfo: nil, repeats: true)

            delay(30) {
                timer.invalidate()
                self.initializeRecursive()
            }

        }.then { _ -> Void in
            Drop.upAll()
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        UINavigationBar.appearance().tintColor = UIColor.TMBlue()

        reachability = getReachability()

        setupHockeyApp()

        initializeRecursive()

        return true
    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {

        if notificationSettings != .none {
            application.registerForRemoteNotifications()
        } else {
            application.unregisterForRemoteNotifications()
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        debugPrint("Registered with device token \(tokenString)")

        TreatMe.client.updateDeviceToken(tokenString)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Failed to register for remote notifications \(error)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        let info = userInfo as NSDictionary as! [String: NSDictionary]

        // If the application is running, update the badge.  Otherwise the system will do it
        if let badge = info["aps"]?["badge"] as? Int , application.applicationState == .active {
            print("Setting badge to \(badge)")
            application.applicationIconBadgeNumber = badge
        }

        let result = handleMessage(userInfo)
        completionHandler(result)
    }

    func handleMessage(_ userInfo: [AnyHashable: Any]) -> UIBackgroundFetchResult {
        if let message = try? Message.decode(userInfo as AnyObject), let channel = TreatMe.data.channels[message.channelId] {
            print("Received \(message)")
            TreatMe.data.insertMessage(message, forChannel: channel, notify: true)
            return .newData
        }
        return .noData
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        PusherClient.instance.stop()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        PusherClient.instance.start()
        NotificationCenter.default.post(name: Notification.Name(rawValue: TreatMeNotifications.RefreshChat.rawValue), object: self)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK - HockeyApp
    func setupHockeyApp() {
        BITHockeyManager.shared().configure(withIdentifier: "aa04e2beee6f43a9a3d1a1eaf29277b6")
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()
        BITHockeyManager.shared().feedbackManager.showAlertOnIncomingMessages = true
    }

    func userID(for hockeyManager: BITHockeyManager!, componentManager: BITHockeyBaseManager!) -> String! {
        return Auth.instance.userHref ?? "Unauthenticated"
    }

}

