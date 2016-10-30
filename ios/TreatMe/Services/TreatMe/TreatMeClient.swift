//
//  TreatMe.swift
//  TreatMe
//
//  Created by Keilan Jackson on 2/27/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

let bootstrapUrl: String = Configuration.instance.get("TreatMe.BootstrapUrl")
let MESSAGE_LIMIT = 50

enum TreatMeError: Error {
    case invalidImage
}

class TreatMeClient {

    var bootstrapData : BootstrapData?

    var authHeaders: [String: String] {
        get {
            return [
                "Authorization": "Bearer \(Auth.instance.accessToken ?? "None")"
            ]
        }
    }

    // Request the bootstrapped urls
    func bootstrap() -> Promise<BootstrapData> {
        if let data = self.bootstrapData {
            return Promise(value: data)
        } else {
            return Alamofire.request(bootstrapUrl).responseObject().then { (data: BootstrapData, _) -> BootstrapData in

                self.bootstrapData = data
                return data
            }
        }
    }

    // Use a username and password to construct a Basic Authorization header to log the user in
    func login(_ username: String, password: String) -> Promise<Void> {
        return bootstrap().then { data in
            let credentialData = "\(username):\(password)".data(using: String.Encoding.utf8)!
            let base64Credentials = credentialData.base64EncodedString()

            let headers = ["Authorization": "Basic \(base64Credentials)"]

            return Alamofire.request(data.login, method: .post, headers: headers)
                .responseObject().then { (data: LoginResult, _) -> Void in
                    Auth.instance.setAuthentication(username, href: data.href, accessToken: data.accessToken, refreshToken: data.refreshToken, expiresIn: data.expiresIn)
                }
        }
    }

    func logout() -> Promise<Void> {
        return bootstrap().then { data in
            return self.withAuthentication() { headers in
                return Alamofire.request(data.logout, method: .post, headers: headers).response()
            }.asVoid()
        }
    }

    // Registers the user
    func registerUser(username: String, email: String, dob: String, zip: String, password: String) -> Promise<Void> {

        return bootstrap().then { data in
            let registerData = [
                "username": username,
                "email": email,
                "dob": dob,
                "zip": zip,
                "password": password
            ]

            return Alamofire.request(data.register, method: .put, parameters: registerData, encoding: JSONEncoding.default).responseObject().then { (data: LoginResult, _) -> Void in

                Auth.instance.setAuthentication(username, href: data.href, accessToken: data.accessToken, refreshToken: data.refreshToken, expiresIn: data.expiresIn)
            }
        }
    }

    // Resets a password using username or email
    func resetPassword(_ identifier: String) -> Promise<Void> {
        return bootstrap().then { data in
            let url = data.resetPassword + identifier
            return Alamofire.request(url).response().asVoid()
        }
    }

    func updateDeviceToken(_ token: String) -> Promise<Void> {
        guard let authUser = TreatMe.data.authenticatedUser, let deviceHref = authUser.deviceTokenHref else {
            return Promise(error: ResponseError.authenticationError)
        }

        return withAuthentication() { headers in

            let data = [
                "token": token
            ]

            return Alamofire.request(deviceHref, method: .put, parameters: data, encoding: JSONEncoding.default, headers: headers).response().asVoid()
        }
    }

    // Gets a user from an href
    func getUser(_ href: String) -> Promise<User> {
        return withAuthentication() { headers in
            return Alamofire.request(href, headers: headers).responseObject().then { (user: User, _) -> User in
                TreatMe.data.userCache[href] = user
                return user
            }
        }
    }

    // Uploads a picture for the authenticated user's profile
    func uploadProfilePicture(_ image: UIImage) -> Promise<String> {
        guard let authUser = TreatMe.data.authenticatedUser,
            let imageHref = authUser.imageHref else {
            return Promise(error: ResponseError.authenticationError)
        }

        var resizedImage = image;
        if image.size.width > 512 || image.size.height > 512 {
            resizedImage = image.resizeToWidth(512, toHeight: 512)
        }

        guard let png = UIImagePNGRepresentation(resizedImage) else {
            return Promise(error: TreatMeError.invalidImage)
        }
        let base64 = png.base64EncodedString()

        return withAuthentication() { headers in

            let (promise, fulfill, reject) = Promise<Response>.pending()

            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(png, withName: "image")
                },
                to: imageHref,
                method: .post,
                headers: headers,
                encodingCompletion: { result in
                    switch result {
                    case .success(let upload, _, _):
                        upload.response().then { res -> Void in
                            fulfill(res)
                        }.catch { error in
                            reject(error)
                        }
                    case .failure(let error): reject(error)
                    }
                }
            )

            return promise.then { res in
                if let data = res.data, let imageLocation = String(data: data, encoding: String.Encoding.utf8) {
                    TreatMe.data.userImages[authUser] = Promise(value: imageLocation)

                    return TreatMe.data.userImages[authUser]!
                } else {
                    return Promise(error: TreatMeError.invalidImage)
                }
            }
        }
    }

    // Get the actual url for a user's image
    func getUserImage(_ user: User) -> Promise<String> {
        guard let imageHref = user.imageHref else {
            return Promise(error: TreatMeError.invalidImage)
        }

        TreatMe.data.userImages[user] = withAuthentication() { headers in
            let noCacheHeaders = headers.insert("cache-control", v: "no-cache")

            return Alamofire.request(imageHref, headers: noCacheHeaders).response().then { res in
                if let data = res.data, let imageLocation = String(data: data, encoding: String.Encoding.utf8) {
                    return Promise(value: imageLocation)
                } else {
                    return Promise(error: TreatMeError.invalidImage)
                }
            }
        }

        return TreatMe.data.userImages[user]!
    }

    // Get the groups that a user belongs to
    func getUserGroups(_ user: User) -> Promise<[Group]> {
        guard let href = user.groupsHref else {
            return Promise(value: [])
        }

        return withAuthentication() { headers in
            Alamofire.request(href, headers: headers).responseArray().then { (groups: [Group], _) -> [Group] in
                TreatMe.data.userGroups[user] = groups
                return groups
            }
        }
    }

    // Returns the first channel where the only members are the given user and authenticated user
    func channelForUser(_ user: User) -> Promise<Channel> {
        if let authUser = TreatMe.data.authenticatedUser {
            if let userChannel = Array(TreatMe.data.userChannels.values).first(where: { $0.otherUser == user }) {
                return Promise(value: userChannel)
            } else {
                return TreatMe.client.requestUserChannel(authUser, withUser: user)
            }
        } else {
            return Promise(error: ResponseError.authorizationError)
        }
    }

    // Get the conversations a user has opened
    fileprivate func getUserChannels(_ user: User) -> Promise<[Channel]> {
        guard let href = user.channelsHref else {
            return Promise(value: [])
        }

        return withAuthentication() { headers in
            Alamofire.request(href, headers: headers).responseArray().then { (chans: [Channel], _) -> [Channel] in
                return chans
            }
        }
    }

    // Request a user channel. If successful, then private messages can be made over the channel
    fileprivate func requestUserChannel(_ authUser: User, withUser user: User) -> Promise<Channel> {
        guard let href = authUser.channelsHref else {
            return Promise(error: ResponseError.badRequest(nil))
        }

        let userChannelData = [
            "users": [user.id, authUser.id]
        ]

        return withAuthentication() { headers in
            Alamofire.request(href, method: .put, parameters: userChannelData, encoding: JSONEncoding.default, headers: headers).responseObject().then { (channel: Channel, _) -> Channel in
                TreatMe.data.userChannels[channel.id] = channel
                return channel
            }
        }
    }

    // Refreshes the authenticated user's user channels
    func refreshUserChannels() -> Promise<Void> {
        return TreatMe.client.getUser(Auth.instance.userHref!)
            .then { user -> Promise<[Channel]> in
                return TreatMe.client.getUserChannels(user)
            }.then { channels -> Void in
                TreatMe.data.userChannels = channels.indexBy { $0.id }
                channels.forEach { TreatMe.data.channelUnread[$0] = $0.unread }
        }.asVoid()
    }

    // Get the channels for a group
    fileprivate func getGroupChannels(_ group: Group) -> Promise<[Channel]> {
        return withAuthentication() { headers in
            Alamofire.request(group.channelsHref, headers: headers).responseArray().then { (channels: [Channel], _) -> [Channel] in
                TreatMe.data.groupChannels[group] = channels
                channels.forEach {
                    print("Channel", $0)
                    TreatMe.data.channelUnread[$0] = $0.unread
                }
                return channels
            }
        }
    }

    // Get the users for a group
    func getGroupUsers(_ group: Group) -> Promise<[User]> {
        return withAuthentication() { headers in
            Alamofire.request(group.usersHref, headers: headers).responseArray().then { (users: [User], _) -> [User] in
                TreatMe.data.groupUsers[group] = users
                return users
            }
        }
    }

    // Refreshes the authenticated user's groups, the group users, and group channels
    func refreshGroups() -> Promise<Void> {
        return TreatMe.client.getUser(Auth.instance.userHref!)
            .then { user -> Promise<[Group]> in
                return TreatMe.client.getUserGroups(user)
            }
            .then { (groups: [Group]) -> Promise<([[Channel]],[[User]])> in
                TreatMe.data.groups = groups.sorted(by: {$0.name < $1.name})

                let getGroupChannels = when(fulfilled: groups.map { group in
                    return TreatMe.client.getGroupChannels(group)
                })

                let getGroupUsers = when(fulfilled: groups.map { group in
                    return TreatMe.client.getGroupUsers(group)
                })

                return when(fulfilled: getGroupChannels, getGroupUsers)
            }.asVoid()
    }


    // Get the messages for a channel
    // if lastMessage is specified, starts from that message
    func getChannelMessages(_ channel: Channel, lastMessage: Message?) -> Promise<[Message]> {
        return withAuthentication() { headers in
            var query: [String: AnyObject] = [
                "limit": MESSAGE_LIMIT as AnyObject
            ]

            if let lastId = lastMessage?.id {
                query["lastId"] = lastId as AnyObject?
            }

            return Alamofire.request(
                channel.messagesHref,
                parameters: query,
                encoding: URLEncoding.queryString,
                headers: headers
            ).responseObject().then { (list: ListMessages, _) -> [Message] in
                TreatMe.data.channelUnread[channel] = list.unread
                return list.messages
            }
        }
    }

    // Post a message to a channel
    func sendMessage(_ message: String, toChannel channel: Channel) -> Promise<Message> {
        return withAuthentication { headers in

            let messageData = [
                "content": message
            ]

            return Alamofire.request(channel.messagesHref, method: .put, parameters: messageData, encoding: JSONEncoding.default, headers: headers).responseObject().then { (message: Message, _) -> Message in

                return message
            }
        }
    }

    // Marks a channel as having been read to update the badge number
    func markChannelRead(_ channel: Channel) -> Promise<Void> {
        return withAuthentication { headers in
            return Alamofire.request(channel.markReadHref, method: .post, headers: headers).response().asVoid().then { _ -> Void in
                TreatMe.data.channelUnread[channel] = 0
            }
        }
    }

    // Checks if the authentication is valid using a lightweight HEAD request
    func checkAuth() -> Promise<Bool> {
        return bootstrap().then { data in
            return self.withAuthentication() { headers in
                return Alamofire.request(data.checkAuth, method: .head, headers: headers).response().then { response in
                    return response.httpResponse.statusCode == 200
                }
            }
        }.recover { error -> Bool in
            switch(error) {
                case ResponseError.authenticationError: return false
                case ResponseError.authorizationError: return false
                default: throw error
            }
        }
    }

    // Performs the authentication refresh
    fileprivate func refreshAuth() -> Promise<[String:String]> {

        guard let refreshToken = Auth.instance.refreshToken, let username = Auth.instance.username else {
            return Promise(error: ResponseError.authenticationError)
        }

        let credentialData = "\(username):\(refreshToken)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString()

        let refreshHeaders = [
            "Authorization": "Basic \(base64Credentials)"
        ]

        return bootstrap().then { data in
            return Alamofire.request(data.refreshAuth, method: .post, headers: refreshHeaders).responseObject().then { (data: RefreshResult, _) -> [String: String] in

                Auth.instance.refreshAccess(data.accessToken, expiresIn: data.expiresIn)
                return self.authHeaders
            }.onError { error in
                debugPrint("Error refreshing authentication: \(error)")

                if let delegate = UIApplication.shared.delegate as? AppDelegate, let window = delegate.window {
                    Flow.goToLogin(window)
                }
            }
        }
    }

    // If the provided promise fails due to authentication, do the auth refresh and try again
    fileprivate func withAuthentication<T>(_ headersOpt: [String: String]? = nil, makeRequest: @escaping ([String: String]) -> Promise<T>) -> Promise<T> {

        let headers = headersOpt ?? [:]

        if Auth.instance.expired() {
            return self.refreshAuth().then { authHeaders in
                let headersWithAuth = headers.merge(authHeaders)
                return makeRequest(headersWithAuth)
            }
        } else {
            let headersWithAuth = headers.merge(authHeaders)
            return makeRequest(headersWithAuth).recover { error -> Promise<T> in
                switch error {
                case ResponseError.authenticationError:
                    return self.refreshAuth().then { authHeaders in
                        let headersWithAuth = headers.merge(authHeaders)
                        return makeRequest(headersWithAuth)
                    }
                default: throw error
                }
            }
        }
    }


}
