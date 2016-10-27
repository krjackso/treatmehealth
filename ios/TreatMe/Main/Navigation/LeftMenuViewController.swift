//
//  LetMenu.swift
//  TreatMe
//
//  Created by Keilan Jackson on 3/5/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import UIKit
import SwiftyDrop

class LeftMenuViewController: UITableViewController {

    var selectedChannel: Channel? {
        get {
            return TreatMe.data.selectedChannel
        }
    }

    var users: [User] {
        get {
            var users = TreatMe.data.users
            if let authUser = TreatMe.data.authenticatedUser, idx = users.indexOf(authUser) {
                users.removeAtIndex(idx)
            }
            return users
        }
    }

    var userChannels: [User: Channel] {
        get {
            var users = TreatMe.data.users
            if let authUser = TreatMe.data.authenticatedUser, idx = users.indexOf(authUser) {
                users.removeAtIndex(idx)
            }

            return users.mapAssociate { user in
                let channel = Array(TreatMe.data.userChannels.values).find { $0.otherUser == user }
                return channel.map { (user, $0) }
            }
        }
    }

    var groupChannels: [Group: [Channel]] {
        get {
            return TreatMe.data.groupChannels
        }
    }

    var groups: [Group] {
        get {
            return Array(self.groupChannels.keys).sort { (g1, g2) in
                g1.name < g2.name
            }
        }
    }

    var usersSection: Int {
        get {
            return self.groups.count
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBarHidden = true

        self.tableView.registerClass(ChannelTableCell.self, forCellReuseIdentifier: ChannelTableCell.Identifier)

        PusherClient.instance.listen(.Channel) { (channelId, event, data: Channel) in
            delay(1.0) { [unowned self] in
                self.tableView.reloadData()
            }
        }

        self.groups.forEach { group in
            if let channel = PusherClient.instance.subscribe(group.id) {
                channel.onUpdateMembers = { members in
                    let presenceUsers = members.flatMap { member -> PresenceUser? in
                        guard let username = member.userInfo?["username"] as? String else {
                            return nil
                        }

                        guard member.userId != TreatMe.data.authenticatedUser?.id else {
                            return nil
                        }

                        return PresenceUser(id: member.userId, username: username)
                    }
                    self.updateOnline(group, users: presenceUsers)
                }
            }
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.updateUnread), name: TreatMeNotifications.RefreshUnread.rawValue, object: nil)
    }

    func updateOnline(group: Group, users: [PresenceUser]) {
        TreatMe.data.onlineGroupUsers[group] = users

        let missingUsers = users.contains({ user in
            return self.users.find { $0.id == user.id } == nil
        })

        if missingUsers {
            TreatMe.client.getGroupUsers(group).then { _ in
                self.tableView.reloadData()
            }
        }

        self.tableView.reloadData()
    }

    func updateUnread() {
        UIView.performWithoutAnimation {
            self.tableView.reloadData()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.tableView.reloadData()
    }

    func closeLeftMenu(sender: AnyObject?) {
        self.evo_drawerController?.closeDrawerAnimated(true, completion: nil)
    }

    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section

        if section < self.groups.count {
            let group = self.groups[section]
            if let channel = self.groupChannels[group]?[indexPath.row] {
                self.selectChannel(channel, atIndex: indexPath)
            }
        } else {
            let user = users[indexPath.row]

            TreatMe.client.channelForUser(user).then { channel -> Void in
                self.selectChannel(channel, atIndex: indexPath)
            }.error { _ in
                Drop.down("Sorry, something went wrong", state: TMState.Error)
            }
        }
    }

    func selectChannel(channel: Channel, atIndex indexPath: NSIndexPath) {
        TreatMe.data.selectedChannelId = channel.id

        UIView.animateWithDuration(0.25, animations: {
            self.tableView.visibleCells.forEach { cell in
                if let cell = cell as? ChannelTableCell {
                    cell.setActive(false)
                }
            }

            if let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? ChannelTableCell {
                cell.setActive(true)
            }
        }, completion: { _ in
            self.closeLeftMenu(self)
        })
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 30.0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let section = indexPath.section

        if section < self.usersSection {
            let group = self.groups[section]
            if let channel = self.groupChannels[group]?[indexPath.row],
               let cell = tableView.dequeueReusableCellWithIdentifier(ChannelTableCell.Identifier) as? ChannelTableCell {
                cell.channelLabel.text = "#" + channel.name

                cell.setActive(TreatMe.data.selectedChannel == channel)
                cell.setOnline(false)
                cell.setUnread(TreatMe.data.channelUnread[channel] ?? 0)

                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCellWithIdentifier(ChannelTableCell.Identifier) as? ChannelTableCell {
                let user = self.users[indexPath.row]
                cell.channelLabel.text = user.username

                if let channel = userChannels[user] {
                    cell.setActive(TreatMe.data.selectedChannel == channel)
                    cell.setUnread(TreatMe.data.channelUnread[channel] ?? 0)
                } else {
                    cell.setActive(false)
                    cell.setUnread(0)
                }

                let online = TreatMe.data.onlineUsers.contains { $0.id == user.id }
                cell.setOnline(online)

                return cell
            }
        }

        return UITableViewCell()
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < self.groups.count {
            return groups[section].name
        } else {
            return "Users"
        }
    }

    // MARK: - UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < self.groups.count {
            return groupChannels[groups[section]]?.count ?? 0
        } else {
            return users.count
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.groupChannels.keys.count + 1
    }

}