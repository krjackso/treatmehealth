//
//  PusherClient.swift
//  TreatMe
//
//  Created by Keilan Jackson on 3/12/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import Foundation
import Decodable
import PusherSwift

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

class AuthRequestBuilder: AuthRequestBuilderProtocol {
    func requestFor(socketID: String, channel: PusherChannel) -> NSMutableURLRequest? {
        let request = NSMutableURLRequest(url: URL(string: PUSHER_AUTH)!)
        request.httpMethod = "POST"
        request.httpBody = "{'socket_id':'\(socketID)','channel_name':'\(channel.name)'}".data(using: String.Encoding.utf8)
        request.addValue(TreatMe.client.authHeaders["Authorization"]!, forHTTPHeaderField: "Authorization")
        return request
    }
}

class PusherClient {

    static let instance = PusherClient()

    let pusher: Pusher = Pusher(
        key: PUSHER_KEY,
        options: PusherClientOptions(
            authMethod: .authRequestBuilder(authRequestBuilder: AuthRequestBuilder()),
            attemptToReturnJSONObject: true,
            encrypted: true
        )
    )

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

    func subscribe(_ id: String) -> PusherPresenceChannel? {
        let pusherId = "presence-" + id

        if let channel = self.pusher.connection.channels.channels[pusherId] {
            return channel as? PusherPresenceChannel
        } else {
            debugPrint("Subscribed to \(pusherId)")
            return self.pusher.subscribe(pusherId) as? PusherPresenceChannel
        }
    }

    // Listens for pusher events that are in the given events and calls the callback with the json parsed data
    func listen<T: Decodable>(_ onlyEvent: PusherClientEvent, callback: @escaping (_ channelId: String, _ event: PusherClientEvent, _ data: T) -> Void) -> String {
        return self.pusher.bind() { (data: Any?) in
            guard let data = data as? [String: AnyObject] else {
                return
            }

            if let channel = data["channel"] as? String,
                let eventString = data["event"] as? String,
                let event = PusherClientEvent(rawValue: eventString) , event == onlyEvent,
                let msg = data["data"] as? NSString,
                let msgData = msg.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false),
                let msgJson = try? JSONSerialization.jsonObject(with: msgData, options: []),
                let data = try? T.decode(msgJson) {
                    let channelId = channel.replacingOccurrences(of: "presence-", with: "", options: .anchored, range: nil)
                    callback(channelId, event, data)
            }
        }
    }

    func unlisten(_ callbackId: String) {
        self.pusher.unbind(callbackId: callbackId)
    }

}
