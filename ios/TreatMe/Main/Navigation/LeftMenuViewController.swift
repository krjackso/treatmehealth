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
            if let authUser = TreatMe.data.authenticatedUser, let idx = users.index(of: authUser) {
                users.remove(at: idx)
            }
            return users
        }
    }

    var userChannels: [User: Channel] {
        get {
            var users = TreatMe.data.users
            if let authUser = TreatMe.data.authenticatedUser, let idx = users.index(of: authUser) {
                users.remove(at: idx)
            }

            return users.mapAssociate { user in
                let channel = Array(TreatMe.data.userChannels.values).first { $0.otherUser == user }
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
            return Array(self.groupChannels.keys).sorted { (g1, g2) in
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

        self.navigationController?.isNavigationBarHidden = true

        self.tableView.register(ChannelTableCell.self, forCellReuseIdentifier: ChannelTableCell.Identifier)

        PusherClient.instance.listen(.Channel) { (channelId, event, data: Channel) in
            delay(1.0) { [unowned self] in
                self.tableView.reloadData()
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUnread), name: NSNotification.Name(rawValue: TreatMeNotifications.RefreshUnread.rawValue), object: nil)
    }

    func updateOnline(_ group: Group, users: [PresenceUser]) {
        TreatMe.data.onlineGroupUsers[group] = users

        let missingUsers = users.contains(where: { user in
            return self.users.first { $0.id == user.id } == nil
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.tableView.reloadData()
    }

    func closeLeftMenu(_ sender: AnyObject?) {
        self.evo_drawerController?.closeDrawer(animated: true, completion: nil)
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = (indexPath as NSIndexPath).section

        if section < self.groups.count {
            let group = self.groups[section]
            if let channel = self.groupChannels[group]?[(indexPath as NSIndexPath).row] {
                self.selectChannel(channel, atIndex: indexPath)
            }
        } else {
            let user = users[(indexPath as NSIndexPath).row]

            TreatMe.client.channelForUser(user).then { channel -> Void in
                self.selectChannel(channel, atIndex: indexPath)
            }.catch { _ in
                Drop.down("Sorry, something went wrong", state: TMState.error)
            }
        }
    }

    func selectChannel(_ channel: Channel, atIndex indexPath: IndexPath) {
        TreatMe.data.selectedChannelId = channel.id

        UIView.animate(withDuration: 0.25, animations: {
            self.tableView.visibleCells.forEach { cell in
                if let cell = cell as? ChannelTableCell {
                    cell.setActive(false)
                }
            }

            if let cell = self.tableView.cellForRow(at: indexPath) as? ChannelTableCell {
                cell.setActive(true)
            }
        }, completion: { _ in
            self.closeLeftMenu(self)
        })
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let section = (indexPath as NSIndexPath).section

        if section < self.usersSection {
            let group = self.groups[section]
            if let channel = self.groupChannels[group]?[(indexPath as NSIndexPath).row],
               let cell = tableView.dequeueReusableCell(withIdentifier: ChannelTableCell.Identifier) as? ChannelTableCell {
                cell.channelLabel.text = "#" + channel.name

                cell.setActive(TreatMe.data.selectedChannel == channel)
                cell.setOnline(false)
                cell.setUnread(TreatMe.data.channelUnread[channel] ?? 0)

                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ChannelTableCell.Identifier) as? ChannelTableCell {
                let user = self.users[(indexPath as NSIndexPath).row]
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

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < self.groups.count {
            return groups[section].name
        } else {
            return "Users"
        }
    }

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < self.groups.count {
            return groupChannels[groups[section]]?.count ?? 0
        } else {
            return users.count
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.groupChannels.keys.count + 1
    }

}
