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

enum TreatMeError: ErrorType {
    case InvalidImage
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
            return Promise(data)
        } else {
            return Alamofire.request(.GET, bootstrapUrl).responseObject().then { (data: BootstrapData, _) -> BootstrapData in

                self.bootstrapData = data
                return data
            }
        }
    }

    // Use a username and password to construct a Basic Authorization header to log the user in
    func login(username: String, password: String) -> Promise<Void> {
        return bootstrap().then { data in
            let credentialData = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
            let base64Credentials = credentialData.base64EncodedStringWithOptions([])

            let headers = ["Authorization": "Basic \(base64Credentials)"]

            return Alamofire.request(.POST, data.login, headers: headers)
                .responseObject().then { (data: LoginResult, _) -> Void in
                    Auth.instance.setAuthentication(username, href: data.href, accessToken: data.accessToken, refreshToken: data.refreshToken, expiresIn: data.expiresIn)
                }
        }
    }

    func logout() -> Promise<Void> {
        return bootstrap().then { data in
            return self.withAuthentication() { headers in
                return Alamofire.request(.POST, data.logout, headers: headers).response().asVoid()
            }
        }
    }

    // Get an invitiation by email to check if one exists
    func getInvitation(email: String) -> Promise<Invitation> {
        return bootstrap().then { data in
            return Alamofire.request(.GET, data.getInvite + email).responseObject().then { (invite: Invitation, res) -> Invitation in
                if res.httpResponse.statusCode == 404 {
                    throw ResponseError.NotFound
                }

                return invite
            }
        }
    }

    // Checks if a username is available
    func checkUsername(username: String) -> Promise<Bool> {
        return bootstrap().then { data in
            return Alamofire.request(.HEAD, data.checkName + username).response().then { res in
                return res.httpResponse.statusCode == 204
            }
        }
    }

    // Registers the user
    func registerUser(email: String, firstName: String, lastName: String, username: String, password: String) -> Promise<Void> {

        return bootstrap().then { data in
            let registerData = [
                "email": email,
                "firstName": firstName,
                "lastName": lastName,
                "username": username,
                "password": password
            ]

            return Alamofire.request(.PUT, data.register, parameters: registerData, encoding: .JSON).responseObject().then { (data: LoginResult, _) -> Void in

                Auth.instance.setAuthentication(username, href: data.href, accessToken: data.accessToken, refreshToken: data.refreshToken, expiresIn: data.expiresIn)
            }
        }
    }

    // Resets a password using username or email
    func resetPassword(identifier: String) -> Promise<Void> {
        return bootstrap().then { data in
            let url = data.resetPassword + identifier
            return Alamofire.request(.GET, url).response().asVoid()
        }
    }

    func updateDeviceToken(token: String) -> Promise<Void> {
        guard let authUser = TreatMe.data.authenticatedUser, deviceHref = authUser.deviceTokenHref else {
            return Promise(error: ResponseError.AuthenticationError)
        }

        return withAuthentication() { headers in

            let data = [
                "token": token
            ]

            return Alamofire.request(.PUT, deviceHref, headers: headers, parameters: data, encoding: .JSON).response().asVoid()
        }
    }

    // Gets a user from an href
    func getUser(href: String) -> Promise<User> {
        return withAuthentication() { headers in
            return Alamofire.request(.GET, href, headers: headers).responseObject().then { (user: User, _) -> User in
                TreatMe.data.userCache[href] = user
                return user
            }
        }
    }

    // Uploads a picture for the authenticated user's profile
    func uploadProfilePicture(image: UIImage) -> Promise<String> {
        guard let authUser = TreatMe.data.authenticatedUser,
            let imageHref = authUser.imageHref else {
            return Promise(error: ResponseError.AuthenticationError)
        }

        var resizedImage = image;
        if image.size.width > 512 || image.size.height > 512 {
            resizedImage = image.resizeToWidth(512, toHeight: 512)
        }

        guard let png = UIImagePNGRepresentation(resizedImage) else {
            return Promise(error: TreatMeError.InvalidImage)
        }
        let base64 = png.base64EncodedDataWithOptions(.EncodingEndLineWithCarriageReturn)

        return withAuthentication() { headers in

            let (promise, fulfill, reject) = Promise<Response>.pendingPromise()

                Alamofire.upload(.POST, imageHref, headers: headers, multipartFormData: { multipart in
                    multipart.appendBodyPart(data: base64, name: "image")
                }) { result in
                    switch result {
                    case .Success(let upload, _, _):
                        upload.response().then { res -> Void in
                            fulfill(res)
                        }.error { error in
                            reject(error)
                        }
                    case .Failure(let error): reject(error)
                    }
                }

            return promise.then { res in
                if let data = res.data, imageLocation = String(data: data, encoding: NSUTF8StringEncoding) {
                    TreatMe.data.userImages[authUser] = Promise(imageLocation)

                    return TreatMe.data.userImages[authUser]!
                } else {
                    return Promise(error: TreatMeError.InvalidImage)
                }
            }
        }
    }

    // Get the actual url for a user's image
    func getUserImage(user: User) -> Promise<String> {
        guard let imageHref = user.imageHref else {
            return Promise(error: TreatMeError.InvalidImage)
        }

        TreatMe.data.userImages[user] = withAuthentication() { headers in
            let noCacheHeaders = headers.insert("cache-control", v: "no-cache")

            return Alamofire.request(.GET, imageHref, headers: noCacheHeaders).response().then { res in
                if let data = res.data, imageLocation = String(data: data, encoding: NSUTF8StringEncoding) {
                    return Promise(imageLocation)
                } else {
                    return Promise(error: TreatMeError.InvalidImage)
                }
            }
        }

        return TreatMe.data.userImages[user]!
    }

    // Get the groups that a user belongs to
    func getUserGroups(user: User) -> Promise<[Group]> {
        guard let href = user.groupsHref else {
            return Promise([])
        }

        return withAuthentication() { headers in
            Alamofire.request(.GET, href, headers: headers).responseArray().then { (groups: [Group], _) -> [Group] in
                TreatMe.data.userGroups[user] = groups
                return groups
            }
        }
    }

    // Returns the first channel where the only members are the given user and authenticated user
    func channelForUser(user: User) -> Promise<Channel> {
        if let authUser = TreatMe.data.authenticatedUser {
            if let userChannel = Array(TreatMe.data.userChannels.values).find({ $0.otherUser == user }) {
                return Promise(userChannel)
            } else {
                return TreatMe.client.requestUserChannel(authUser, withUser: user)
            }
        } else {
            return Promise(error: ResponseError.AuthorizationError)
        }
    }

    // Get the conversations a user has opened
    private func getUserChannels(user: User) -> Promise<[Channel]> {
        guard let href = user.channelsHref else {
            return Promise([])
        }

        return withAuthentication() { headers in
            Alamofire.request(.GET, href, headers: headers).responseArray().then { (chans: [Channel], _) -> [Channel] in
                return chans
            }
        }
    }

    // Request a user channel. If successful, then private messages can be made over the channel
    private func requestUserChannel(authUser: User, withUser user: User) -> Promise<Channel> {
        guard let href = authUser.channelsHref else {
            return Promise(error: ResponseError.BadRequest)
        }

        let userChannelData = [
            "users": [user.id, authUser.id]
        ]

        return withAuthentication() { headers in
            Alamofire.request(.PUT, href, headers: headers, parameters: userChannelData, encoding: .JSON).responseObject().then { (channel: Channel, _) -> Channel in
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
    private func getGroupChannels(group: Group) -> Promise<[Channel]> {
        return withAuthentication() { headers in
            Alamofire.request(.GET, group.channelsHref, headers: headers).responseArray().then { (channels: [Channel], _) -> [Channel] in
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
    func getGroupUsers(group: Group) -> Promise<[User]> {
        return withAuthentication() { headers in
            Alamofire.request(.GET, group.usersHref, headers: headers).responseArray().then { (users: [User], _) -> [User] in
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
                TreatMe.data.groups = groups.sort({$0.name < $1.name})

                let getGroupChannels = when(groups.map { group in
                    return TreatMe.client.getGroupChannels(group)
                })

                let getGroupUsers = when(groups.map { group in
                    return TreatMe.client.getGroupUsers(group)
                })

                return when(getGroupChannels, getGroupUsers)
            }.asVoid()
    }


    // Get the messages for a channel
    // if lastMessage is specified, starts from that message
    func getChannelMessages(channel: Channel, lastMessage: Message?) -> Promise<[Message]> {
        return withAuthentication() { headers in
            var query: [String: AnyObject] = [
                "limit": MESSAGE_LIMIT
            ]

            if let lastId = lastMessage?.id {
                query["lastId"] = lastId
            }

            return Alamofire.request(
                .GET,
                channel.messagesHref,
                headers: headers,
                parameters: query
            ).responseObject().then { (list: ListMessages, _) -> [Message] in
                TreatMe.data.channelUnread[channel] = list.unread
                return list.messages
            }
        }
    }

    // Post a message to a channel
    func sendMessage(message: String, toChannel channel: Channel) -> Promise<Message> {
        return withAuthentication { headers in

            let messageData = [
                "content": message
            ]

            return Alamofire.request(.PUT, channel.messagesHref, headers: headers, parameters: messageData, encoding: .JSON).responseObject().then { (message: Message, _) -> Message in

                return message
            }
        }
    }

    // Marks a channel as having been read to update the badge number
    func markChannelRead(channel: Channel) -> Promise<Void> {
        return withAuthentication { headers in
            return Alamofire.request(.POST, channel.markReadHref, headers: headers).response().asVoid().then { _ -> Void in
                TreatMe.data.channelUnread[channel] = 0
            }
        }
    }

    // Checks if the authentication is valid using a lightweight HEAD request
    func checkAuth() -> Promise<Bool> {
        return bootstrap().then { data in
            return self.withAuthentication() { headers in
                return Alamofire.request(.HEAD, data.checkAuth, headers: headers).response().then { response in
                    return response.httpResponse.statusCode == 200
                }
            }
        }.recover { error -> Bool in
            switch(error) {
                case ResponseError.AuthenticationError: return false
                case ResponseError.AuthorizationError: return false
                default: throw error
            }
        }
    }

    // Performs the authentication refresh
    private func refreshAuth() -> Promise<[String:String]> {

        guard let refreshToken = Auth.instance.refreshToken else {
            return Promise(error: ResponseError.AuthenticationError)
        }

        let refreshData = [
            "refreshToken": refreshToken
        ]

        return bootstrap().then { data in
            return Alamofire.request(.POST, data.refresh, parameters: refreshData, encoding: .JSON).responseObject().then { (data: RefreshResult, _) -> [String: String] in

                Auth.instance.refreshAccess(data.accessToken, expiresIn: data.expiresIn)
                return self.authHeaders
            }.onError { error in
                debugPrint("Error refreshing authentication: \(error)")

                if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate, window = delegate.window {
                    Flow.goToLogin(window)
                }
            }
        }
    }

    // If the provided promise fails due to authentication, do the auth refresh and try again
    private func withAuthentication<T>(headersOpt: [String: String]? = nil, makeRequest: ([String: String]) -> Promise<T>) -> Promise<T> {

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
                case ResponseError.AuthenticationError:
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