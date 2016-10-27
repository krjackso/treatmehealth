//
//  TreatMeData.swift
//  TreatMe
//
//  Created by Keilan Jackson on 3/4/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import Decodable
import Swiftz
import KeychainSwift
import PromiseKit

struct BootstrapData: Decodable {
    let login: String
    let register: String
    let logout: String
    let refresh: String
    let checkAuth: String
    let getInvite: String
    let checkName: String
    let pusherAuth: String
    let resetPassword: String

    static func decode(json: AnyObject) throws -> BootstrapData {
        return try BootstrapData(
            login: json => "login",
            register: json => "register",
            logout: json => "logout",
            refresh: json => "refresh",
            checkAuth: json => "checkAuth",
            getInvite: json => "getInvite",
            checkName: json => "checkName",
            pusherAuth: json => "pusherAuth",
            resetPassword: json => "resetPassword"
        )
    }
}

struct RefreshResult: Decodable {
    let accessToken: String
    let expiresIn: Double

    static func decode(json: AnyObject) throws -> RefreshResult {
        return try RefreshResult(
            accessToken: json => "accessToken",
            expiresIn: json => "expiresIn"
        )
    }
}

struct LoginResult: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Double
    let href: String

    static func decode(json: AnyObject) throws -> LoginResult {
        return try LoginResult(
            accessToken: json => "accessToken",
            refreshToken: json => "refreshToken",
            expiresIn: json => "expiresIn",
            href: json => "href"
        )
    }
}

struct Invitation: Decodable {
    let firstName: String
    let lastName: String

    static func decode(json: AnyObject) throws -> Invitation {
        return try Invitation(
            firstName: json => "firstName",
            lastName: json => "lastName"
        )
    }
}

struct Group: Hashable, Decodable {
    let href: String
    let id: String
    let name: String
    let description: String
    let channelsHref: String
    let usersHref: String

    var hashValue: Int {
        return id.hashValue
    }

    static func decode(json: AnyObject) throws -> Group {
        return try Group(
            href: json => "href",
            id: json => "id",
            name: json => "name",
            description: json => "description",
            channelsHref: json => "channels",
            usersHref: json => "users"
        )
    }

}
func ==(lhs: Group, rhs: Group) -> Bool {
    return lhs.id == rhs.id
}

struct Channel: Hashable, Decodable {
    let href: String
    let id: String
    let name: String
    let tags: [String]
    let users: [String]
    let groupId: String?
    let messagesHref: String
    let markReadHref: String
    let unread: Int?

    var hashValue: Int {
        return id.hashValue
    }

    static func decode(json: AnyObject) throws -> Channel {
        return try Channel(
            href: json => "href",
            id: json => "id",
            name: json => "name",
            tags: json => "tags",
            users: json => "users",
            groupId: json =>? "groupId",
            messagesHref: json => "messages",
            markReadHref: json => "markRead",
            unread: json =>? "unread"
        )
    }

    func displayName() -> String {
        if self.groupId != nil {
            return self.name
        } else {
            if let authUser = TreatMe.data.authenticatedUser {
                let otherUsers = self.users.filter { $0 != authUser.id }
                let usernames = otherUsers.mapMaybe { TreatMe.data.idUsers[$0]?.username }
                return usernames.joinWithSeparator(", ")
            } else {
                return ""
            }
        }
    }

    // Returns the non-authetnicated user in a channel. If there is more than one user, returns the first one
    var otherUser: User? {
        get {
            var users = self.users.mapMaybe { TreatMe.data.idUsers[$0] }
            if let authUser = TreatMe.data.authenticatedUser, idx = users.indexOf(authUser) {
                users.removeAtIndex(idx)
            }

            return users.first
        }
    }
}
func ==(lhs: Channel, rhs: Channel) -> Bool {
    return lhs.id == rhs.id
}

struct User: Hashable, Decodable {
    var id: String
    var username: String
    var firstName: String?
    var lastName: String?
    var groupsHref: String?
    var channelsHref: String?
    var imageHref: String?
    var settingsHref: String?
    var deviceTokenHref: String?

    var hashValue: Int {
        return id.hashValue
    }

    static func decode(json: AnyObject) throws -> User {
        return try User(
            id: json => "id",
            username: json => "username",
            firstName: json =>? "firstName",
            lastName: json =>? "lastName",
            groupsHref: json =>? "groups",
            channelsHref: json =>? "channels",
            imageHref: json =>? "image",
            settingsHref: json =>? "settings",
            deviceTokenHref: json =>? "deviceTokens"
        )
    }
}
func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
}

struct Message: Hashable, Decodable {
    let id: String
    let content: String
    let time: NSDate
    let userId: String
    let channelId: String

    var hashValue: Int {
        return id.hashValue
    }

    static func decode(json: AnyObject) throws -> Message {
        return try Message(
            id: json => "id",
            content: json => "content",
            time: json => "created",
            userId: json => "userId",
            channelId: json => "channelId"
        )
    }
}
func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.id == rhs.id
}

struct ListMessages: Decodable {
    let unread: Int
    let messages: [Message]

    static func decode(json: AnyObject) throws -> ListMessages {
        return try ListMessages(
            unread: json => "unread",
            messages: json => "messages"
        )
    }
}

struct PusherMessage: Decodable {
    let message: Message
    let unread: Int?
    let notifies: [String]?

    static func decode(json: AnyObject) throws -> PusherMessage {
        return try PusherMessage(
            message: json => "message",
            unread: json =>? "unread",
            notifies: json =>? "notifies"
        )
    }
}

enum TreatMeNotifications: String {
    case RefreshChat = "RefreshChat"
    case NewMessage = "NewMessage"
    case RefreshUserImage = "RefreshUserImage"
    case RefreshUnread = "RefreshUnread"
}

class TreatMeData {

    let keychain = KeychainSwift()

    var selectedChannelId: String? {
        get {
            return keychain.get("selectedChannelId")
        }
        set(value) {
            if let val = value {
                keychain.set(val, forKey: "selectedChannelId")
                NSNotificationCenter.defaultCenter().postNotificationName(TreatMeNotifications.RefreshChat.rawValue, object: self)
            }
        }
    }

    var selectedChannel: Channel? {
        get {
            return selectedChannelId.flatMap { id in
                return self.channels[id]
            }
        }
    }

    var authenticatedUser: User? {
        get {
            return Auth.instance.userHref.flatMap({self.userCache[$0]})
        }
    }

    // Groups
    var groups: [Group] = []

    // Channel id to channel
    var userChannels: [String: Channel] = [:]

    // User href to User
    var userCache: [String: User] = [:]

    // User to Groups
    var userGroups: [User: [Group]] = [:]

    // User to signed image url
    var userImages: [User: Promise<String>] = [:]

    // Group to group channels
    var groupChannels: [Group: [Channel]] = [:]

    // Group to users
    var groupUsers: [Group: [User]] = [:]

    // Channel to messages
    private(set) var channelMessages: [Channel: [Message]] = [:]

    // Channel id to channel for group and user channels
    var channels: [String: Channel] {
        get {
            let groupChannels = Array(self.groupChannels.values.flatten()).indexBy { $0.id }
            return groupChannels.merge(userChannels)
        }
    }

    var channelUnread: [Channel: Int] = [:] {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(TreatMeNotifications.RefreshUnread.rawValue, object: self)
        }
    }

    // All users from all groups
    var users: [User] {
        get {
            return Array(Set(self.groupUsers.values.flatten()))
        }
    }

    // User ids to users
    var idUsers: [String: User] {
        get {
            return self.users.indexBy { $0.id }
        }
    }

    var idMessages: [String: Message] {
        get {
            return Array(channelMessages.values.flatten()).indexBy { $0.id }
        }
    }

    var idGroups: [String: Group] {
        get {
            return self.groups.indexBy { $0.id }
        }
    }

    // Users with presence data
    var onlineGroupUsers: [Group: [PresenceUser]] = [:]
    var onlineUsers: [PresenceUser] {
        get {
            return Array(self.onlineGroupUsers.values.flatten())
        }
    }

    init() {
        PusherClient.instance.listen(.Channel) { (channelId, event, channel: Channel) in
            if let groupId = channel.groupId,
                let group = self.groups.find({$0.id == groupId}) {
                    guard self.groupChannels[group]?.find({$0.id == channel.id}) == nil else {
                        return
                    }

                    self.groupChannels[group]?.insert(channel, atIndex: 0)
            } else {
                guard self.userChannels[channel.id] == nil else {
                    return
                }

                self.userChannels[channel.id] = channel
            }
        }

        PusherClient.instance.listen(.Message) { (channel, event, pMessage: PusherMessage) in
            let message = pMessage.message
            if let channel = TreatMe.data.channels[message.channelId] {
                TreatMe.data.insertMessage(message, forChannel: channel, notify: true)

                if let unread = pMessage.unread {
                    TreatMe.data.channelUnread[channel] = unread
                } else if let notifyUsers = pMessage.notifies,
                    authId = TreatMe.data.authenticatedUser?.id where notifyUsers.contains(authId) {

                    let oldValue = TreatMe.data.channelUnread[channel] ?? 0
                    TreatMe.data.channelUnread[channel] = oldValue + 1
                }
            }
        }

    }

    // Inserts a message and returns the index of the message that was inserted
    func insertMessage(message: Message, forChannel channel: Channel, notify: Bool) -> Int? {
        if let (_, index) = insertMessages([message], forChannel: channel, notify: notify).first {
            return index
        }
        return nil
    }

    // Inserts messages and returns the index each was inserted at
    func insertMessages(messages: [Message], forChannel channel: Channel, notify: Bool) -> [Message: Int] {
        return synchronized(self) {
            if self.channelMessages[channel] == nil {
                self.channelMessages[channel] = []
            }

            let newMessages = messages.filter({ !self.channelMessages[channel]!.contains($0) })

            if !newMessages.isEmpty {
                self.channelMessages[channel]!.insertContentsOf(newMessages, at: 0)
                self.channelMessages[channel]!.sortInPlace({$0.time > $1.time})

                if notify {
                    newMessages.forEach { message in
                        let info = [
                            "channel": channel.id,
                            "message": message.id,
                            "index": self.channelMessages[channel]?.indexOf(message) ?? 0
                        ] as [NSObject: AnyObject]

                        NSNotificationCenter.defaultCenter().postNotificationName(TreatMeNotifications.NewMessage.rawValue, object: self, userInfo: info)
                    }
                }
            }

            return messages.mapAssociate { message in
                self.channelMessages[channel]?.indexOf(message).map { (message, $0) }
            }
        }
    }

    // Replaces the messages for a channel.  Assumes the caller handles the data change afterwards.
    func replaceMessages(messages: [Message], forChannel channel: Channel) {
        return synchronized(self) {
            self.channelMessages[channel] = messages.sort({$0.time > $1.time})
        }
    }

}

