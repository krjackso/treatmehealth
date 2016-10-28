//
//  AuthenticationItems.swift
//  TreatMe
//
//  Created by Keilan Jackson on 2/27/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import Foundation
import KeychainSwift

class Auth {

    static let instance = Auth()

    let keychain = KeychainSwift()

    var username: String? {
        get {
            return UserDefaults.standard.string(forKey: "username")
        }
        set(val) {
            UserDefaults.standard.set(val!, forKey: "username")
        }
    }

    var userHref: String? {
        get {
            return keychain.get("userHref")
        }
        set(val) {
            keychain.set(val!, forKey: "userHref")
        }
    }

    var accessToken: String? {
        get {
            return keychain.get("accessToken")
        }
        set(val) {
            keychain.set(val!, forKey: "accessToken")
        }
    }

    var refreshToken: String? {
        get {
            return keychain.get("refreshToken")
        }
        set(val) {
            keychain.set(val!, forKey: "refreshToken")
        }
    }

    var accessExpires: Date? {
        get {
            return keychain.get("accessExpires").flatMap { value in
                if let interval = TimeInterval(value) {
                    return NSDate(timeIntervalSince1970: interval) as Date
                } else {
                    return nil
                }
            }
        }
        set(val) {
            keychain.set("\(val!.timeIntervalSince1970)", forKey: "accessExpires")
        }
    }

    func setAuthentication(_ username: String, href: String, accessToken: String, refreshToken: String?, expiresIn: Double) {
        self.username = username
        self.userHref = href
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.accessExpires = Date().addingTimeInterval(expiresIn)
    }

    func refreshAccess(_ accessToken: String, expiresIn: Double) {
        self.accessToken = accessToken
        self.accessExpires = Date().addingTimeInterval(expiresIn)
    }

    func expired() -> Bool {
        return accessExpires == nil || accessExpires! < Date()
    }

    func isSet() -> Bool {
        return username != nil && accessToken != nil && refreshToken != nil && accessExpires != nil && userHref != nil
    }

    func clear() -> Bool {
        return keychain.clear()
    }

}
