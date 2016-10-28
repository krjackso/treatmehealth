//
//  Configuration.swift
//  TreatMe
//
//  Created by Keilan Jackson on 4/6/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import Foundation

class Configuration {

    static let instance = Configuration()

    fileprivate let configName = Bundle.main.object(forInfoDictionaryKey: "Configuration") as! String
    fileprivate let configFile = Bundle.main.path(forResource: "Configuration", ofType: "plist")!

    fileprivate lazy var config: [String: AnyObject] = { [unowned self] in
        let allConfigs = NSDictionary(contentsOfFile: self.configFile) as! [String: AnyObject]
        return allConfigs[self.configName] as! [String: AnyObject]
    }()

    func get<T>(_ key: String) -> T {
        if let val = config[key] as? T {
            return val
        } else {
            debugPrint("Key \(key) not found in config!")
            return config[key] as! T
        }
    }

    func get<T>(_ key: String) -> T? {
        return config[key] as? T
    }

}
