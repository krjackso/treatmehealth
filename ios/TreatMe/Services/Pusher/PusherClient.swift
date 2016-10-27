//
//  PusherClient.swift
//  TreatMe
//
//  Created by Keilan Jackson on 3/12/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import Foundation
import Decodable

let PUSHER_AUTH: String = Configuration.instance.get("Pusher.AuthUrl")
let PUSHER_KEY: String = Configuration.instance.get("Pusher.Key")

enum PusherClientEvent: String {
    case Message = "new-message"
    case Channel = "new-channel"
}

struct PresenceUser {
    let id: String
    let username: String
}

class PusherClient {

    static let instance = PusherClient()

    let pusher: Pusher = Pusher(
        key: PUSHER_KEY,
        options: [
            "authEndpoint": PUSHER_AUTH,
            "encrypted": true,
            "authRequestCustomizer": PusherClient.addAuthorizationHeader,
            "attemptToReturnJSONObject": true
        ]
    )

    static func addAuthorizationHeader(req: NSMutableURLRequest) -> NSMutableURLRequest {
        req.addValue(TreatMe.client.authHeaders["Authorization"]!, forHTTPHeaderField: "Authorization")
        return req
    }

    func start() {
        // Subscribe to every group the user has access to
        TreatMe.data.groups.forEach { group in
            self.subscribe(group.id)
        }

        // Subscribe to the channel for the user
        if let user = TreatMe.data.authenticatedUser {
            self.subscribe(user.id)
        }

        self.pusher.connect()
    }

    func stop() {
        // Unsubscribe from all channels
        self.pusher.connection.channels.channels.forEach { (_, channel) in
            self.pusher.unsubscribe(channel.name)
        }
        self.pusher.connection.channels.channels.removeAll()

        self.pusher.disconnect()
    }

    func subscribe(id: String) -> PresencePusherChannel? {
        let pusherId = "presence-" + id

        if let channel = self.pusher.connection.channels.channels[pusherId] {
            return channel as? PresencePusherChannel
        } else {
            debugPrint("Subscribed to \(pusherId)")
            return self.pusher.subscribe(pusherId) as? PresencePusherChannel
        }
    }

    // Listens for pusher events that are in the given events and calls the callback with the json parsed data
    func listen<T: Decodable>(onlyEvent: PusherClientEvent, callback: (channelId: String, event: PusherClientEvent, data: T) -> Void) -> String {
        return self.pusher.bind() { (data: AnyObject?) in
            guard let data = data as? [String: AnyObject] else {
                return
            }

            if let channel = data["channel"] as? String,
                let eventString = data["event"] as? String,
                let event = PusherClientEvent(rawValue: eventString) where event == onlyEvent,
                let msg = data["data"] as? NSString,
                let msgData = msg.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false),
                let msgJson = try? NSJSONSerialization.JSONObjectWithData(msgData, options: []),
                let data = try? T.decode(msgJson) {
                    let channelId = channel.stringByReplacingOccurrencesOfString("presence-", withString: "", options: .AnchoredSearch, range: nil)
                    callback(channelId: channelId, event: event, data: data)
            }
        }
    }

    func unlisten(callbackId: String) {
        self.pusher.unbind(callbackId)
    }

}