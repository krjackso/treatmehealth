//
//  ChatViewController.swift
//  TreatMe
//
//  Created by Keilan Jackson on 3/4/16.
//  Copyright © 2016 TreatMe Health. All rights reserved.
//

import UIKit
import PromiseKit
import SlackTextViewController
import SwiftyDrop

class ChatViewController: SLKTextViewController {

    let loadMoreMessagesThreshold = 10
    let initialMessages = MESSAGE_LIMIT

    var loadingMessages = false
    var shouldLoadMessages = true
    var canSendMessage = true

    var searchableGroups: [Group] {
        get {
            return self.selectedChannel.map { channel -> [Group] in
                // For a group channel just return the group
                if let groupId = channel.groupId, group = TreatMe.data.idGroups[groupId] {
                    return [group]
                }

                // For a user channel return the groups that user is in
                if let otherUser = channel.otherUser {
                    return TreatMe.data.groups.filter { group in
                        return TreatMe.data.groupUsers[group]?.contains(otherUser) ?? false
                    }
                }

                return []
            } ?? []
        }
    }

    var selectedChannel: Channel? {
        get {
            return TreatMe.data.selectedChannel
        }
    }

    var messages: [Message] {
        get {
            var channelMessages = self.selectedChannel.flatMap({TreatMe.data.channelMessages[$0]}) ?? []
            if let pending = pendingMessage {
                channelMessages.insert(pending, atIndex: 0)
            }
            return channelMessages
        }
    }

    var pendingMessage: Message?

    var userHandles: [String] {
        get {
            let users = self.searchableGroups.flatMap { TreatMe.data.groupUsers[$0] }.flatten()
            return users.map { $0.username }
        }
    }

    var tagChannels: [String: Channel] {
        get {
            let channels = self.searchableGroups.flatMap { TreatMe.data.groupChannels[$0] }.flatten()
            return channels.reduce([String: Channel]()) { (sofar, channel) in
                var result = sofar
                channel.tags.forEach { tag in
                    result[tag] = channel
                }
                result[channel.name] = channel
                return result
            }
        }
    }

    lazy var refreshControl: UIRefreshControl = { [unowned self] in
        let control = UIRefreshControl()
        control.tintColor = UIColor.TMBlue()
        control.attributedTitle = NSAttributedString(string: "Loading more messages...")
        control.addTarget(self, action: #selector(refreshMessages), forControlEvents: .ValueChanged)
        return control
    }()

    lazy var collectionBackground: UIView = { [unowned self] in
        let view = UIView(frame: self.collectionView.frame)
        view.backgroundColor = UIColor.whiteColor()

        let message = UILabel(frame: CGRect(x: 0, y: 10, width: self.view.frame.width, height: 20))
        message.text = "All messages loaded!"
        message.font = UIFont.italicSystemFontOfSize(11.0)
        message.textColor = UIColor.darkGrayColor()
        message.textAlignment = .Center

        view.addSubview(message)

        return view
    }()

    lazy var titleView: ChatTitleView = {
        let view = ChatTitleView()
        view.setOnline(false)
        return view
    }()

    var searchResult: [String] = []

    let autocompleteCellHeight: CGFloat = 40.0
    let autocompleteCellIdentifier = "AutocompleteCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureViews()

        self.loadMessages().then {
            self.refreshView()
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(switchChannel), name: TreatMeNotifications.RefreshChat.rawValue, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newMessage), name: TreatMeNotifications.NewMessage.rawValue, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func switchChannel() {
        self.shouldLoadMessages = true

        if self.messages.count < self.initialMessages {
            self.loadMessages().then { [weak self] _ -> Void in
                self?.refreshView()
                self?.markRead()
            }
        } else {
            self.refreshView()
            self.markRead()
        }
    }

    func markRead() {
        if let channel = self.selectedChannel, unread = TreatMe.data.channelUnread[channel] where unread > 0 {
            TreatMe.client.markChannelRead(channel)
        }
    }

    func newMessage(notification: NSNotification) {
        let channelId = notification.userInfo?["channel"] as! String
        let messageId = notification.userInfo?["message"] as! String
        let index = notification.userInfo?["index"] as! Int

        if let channel = TreatMe.data.channels[channelId], message = TreatMe.data.idMessages[messageId] {

            if channel == self.selectedChannel {
                let idxPath = NSIndexPath(forItem: index, inSection: 0)
                self.collectionView.insertItemsAtIndexPaths([idxPath])
            } else {
                // See if the message was a user channel or contained the authenticated users handle
                // and show an alert

                if let user = TreatMe.data.idUsers[message.userId] {
                    if channel.groupId == nil {
                        Drop.down("New message from @\(user.username)", state: TMState.Info, duration: 3.0) {
                            TreatMe.data.selectedChannelId = channel.id
                        }
                    } else {
                        if let authUser = TreatMe.data.authenticatedUser where
                            message.content.containsString("@\(authUser.username)") {
                            Drop.down("@\(user.username) mentioned you in #\(channel.displayName())", state: TMState.Info, duration: 3.0) {
                                TreatMe.data.selectedChannelId = channel.id
                            }
                        }
                    }
                }
            }

        } else {
            // Somehow got a message for a channel we don't know about, so reload channels
            when(TreatMe.client.refreshUserChannels(), TreatMe.client.refreshGroups())
                .error { _ in
                    Drop.down("Sorry, something went wrong.", state: TMState.Error)
            }

        }

    }

    func refreshView() {
        self.title = self.selectedChannel?.displayName()
        self.titleView.channelLabel.text = self.title

        if let selected = self.selectedChannel, user = selected.otherUser {
            self.titleView.setOnline(TreatMe.data.onlineUsers.contains({ $0.id == user.id }))
        } else {
            self.titleView.setOnline(false)
        }

        self.collectionView.reloadData()
        self.view.setNeedsLayout()
    }

    func leftNavButtonPress() {
        self.dismissKeyboard(false)
        self.evo_drawerController?.toggleLeftDrawerSideAnimated(true, completion: nil)
    }

    func rightNavButtonPress() {
        self.dismissKeyboard(false)
        let profile = ProfileViewController(user: TreatMe.data.authenticatedUser!)
        self.presentViewController(profile, animated: true, completion: nil)
    }

    func configureViews() {
        self.navigationItem.titleView = titleView
        self.title = self.selectedChannel?.displayName()
        self.titleView.channelLabel.text = self.title

        let menuImage = UIImage(named: "menu-icon")
        let leftDrawerButton = UIBarButtonItem(image: menuImage, style: .Plain, target: self, action: #selector(leftNavButtonPress))
        leftDrawerButton.tintColor = UIColor.blackColor()
        self.navigationItem.setLeftBarButtonItem(leftDrawerButton, animated: false)
        self.evo_drawerController?.maximumLeftDrawerWidth = 240

        let profileImage = UIImage(named: "profile-icon")
        let showProfileButton = UIBarButtonItem(image: profileImage, style: .Plain, target: self, action: #selector(rightNavButtonPress))
        showProfileButton.tintColor = UIColor.blackColor()
        self.navigationItem.setRightBarButtonItem(showProfileButton, animated: false)
        self.evo_drawerController?.maximumRightDrawerWidth = 240

        self.bounces = true
        self.keyboardPanningEnabled = false
        self.inverted = true

        self.textView.placeholder = "Message"
        self.textView.placeholderColor = UIColor.lightGrayColor()

        self.leftButton.tintColor = UIColor.grayColor()
        self.rightButton.setTitle("Send", forState: UIControlState.Normal)

        self.textInputbar.autoHideRightButton = true
        self.textInputbar.counterStyle = .None

        self.typingIndicatorView?.canResignByTouch = true

        let cellNib: UINib = UINib(nibName: "MessageCell", bundle: NSBundle.mainBundle())
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: MessageCell.identifier)
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.addSubview(self.refreshControl)
        self.collectionView.backgroundView = self.collectionBackground
        self.collectionBackground.transform = self.collectionView.transform

        self.refreshControl.transform = self.collectionView.transform

        self.edgesForExtendedLayout = UIRectEdge.None
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()

        self.autoCompletionView.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.autocompleteCellIdentifier)

        self.registerPrefixesForAutoCompletion(["@", "#"])
    }

    func refreshMessages(refreshControl: UIRefreshControl) {
        guard !loadingMessages, let channel = self.selectedChannel else {
            return
        }

        refreshControl.beginRefreshing()
        self.loadingMessages = true
        TreatMe.client.getChannelMessages(channel, lastMessage: nil).then { messages -> Void in
            TreatMe.data.replaceMessages(messages, forChannel: channel)
            self.shouldLoadMessages = true
            self.collectionView?.reloadData()
        }.always {
            refreshControl.endRefreshing()
            self.loadingMessages = false
        }
    }

    func loadMessages() -> Promise<Void> {
        guard shouldLoadMessages && !loadingMessages, let channel = self.selectedChannel else {
            return Promise().asVoid()
        }

        self.loadingMessages = true
        return TreatMe.client.getChannelMessages(channel, lastMessage: self.messages.last).then { [unowned self] messages -> Void in

            TreatMe.data.insertMessages(messages, forChannel: channel, notify: false)

            if (messages.count < MESSAGE_LIMIT) {
                self.shouldLoadMessages = false
            }
        }.onError { _ in
            Drop.down("Uh oh, something went wrong. Try again in a sec.", state: TMState.Error, duration: 1.0)
        }.always {
            self.loadingMessages = false
        }.asVoid()
    }

    // MARK: - Events
    override func canPressRightButton() -> Bool {
        if canSendMessage {
            return super.canPressRightButton()
        }

        return false
    }

    override func didPressRightButton(sender: AnyObject!) {
        // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
        textView.refreshFirstResponder()

        if self.canSendMessage {
            if let channel = self.selectedChannel, text = self.textView.text {
                self.canSendMessage = false
                self.rightButton.enabled = false

                self.pendingMessage = Message(id: "pending", content: text, time: NSDate(), userId: TreatMe.data.authenticatedUser!.id, channelId: channel.id)
                self.collectionView.reloadData()
                super.didPressRightButton(sender)

                TreatMe.client.sendMessage(text, toChannel: channel).then { message -> Void in
                    self.pendingMessage = nil
                    if let index = TreatMe.data.insertMessage(message, forChannel: channel, notify: false) {
                        let paths = (0...index).map { NSIndexPath(forItem: $0, inSection: 0) }
                        UIView.performWithoutAnimation {
                            self.collectionView.reloadItemsAtIndexPaths(paths)
                        }
                    }
                }.onError { _ in
                    Drop.down("Woops! Your message was not sent. Please try again.", state: TMState.Error, duration: 5.0)
                    self.textView.text = self.pendingMessage?.content
                    self.pendingMessage = nil
                    self.collectionView.reloadData()
                }.always {
                    self.canSendMessage = true
                    self.rightButton.enabled = true
                }
            }
        }

    }

    func didTapHashtag(tag: String) {
        if let channel = self.tagChannels[tag] where channel != self.selectedChannel {
            animateToChannel(channel)
        }
    }

    func didTapMention(mention: String) {
        if let user = TreatMe.data.users.find({ $0.username == mention }) where user != TreatMe.data.authenticatedUser {
            goToChannelForUser(user)
        }
    }

    func didTapUrl(url: NSURL) {
        let lowerString = url.absoluteString.lowercaseString
        if lowerString.hasPrefix("http://") || lowerString.hasPrefix("https://") {
            UIApplication.sharedApplication().openURL(url)
        } else if let url = NSURL(string: "http://\(lowerString)"){
            UIApplication.sharedApplication().openURL(url)
        }
    }

    private func goToChannelForUser(user: User) {
        TreatMe.client.channelForUser(user).then { channel -> Void in
            self.animateToChannel(channel)
            }.error { _ in
                Drop.down("Sorry, something went wrong.", state: TMState.Error, duration: 5.0)
        }
    }

    private func animateToChannel(channel: Channel) {
        let blackView = UIView(frame: self.view.frame)
        blackView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(blackView)

        UIView.animateWithDuration(0.25, animations: {
            TreatMe.data.selectedChannelId = channel.id
            blackView.alpha = 0.0
            }, completion: { finished in
                blackView.removeFromSuperview()
        })
    }

    // MARK: - UICollectionViewDataSource

    override class func collectionViewLayoutForCoder(decoder: NSCoder) -> UICollectionViewLayout {
        let layout = MessageCollectionViewLayout()
        return layout
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        // If the item being requested is the last one, load more messages
        if self.shouldLoadMessages && indexPath.row >= self.messages.count - loadMoreMessagesThreshold {
            self.loadMessages().then { [weak self] _ -> Void in
                self?.refreshView()
            }
        }

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(MessageCell.identifier, forIndexPath: indexPath) as! MessageCell

        let message = self.messages[indexPath.row]

        if message == self.pendingMessage {
            cell.alpha = 0.5
        }

        cell.messageLabel.customize { label in
            label.text = message.content
            label.filterHashtag { tag in self.tagChannels.keys.contains(tag) }
            label.filterMention { mention in self.userHandles.contains(mention) }
            label.handleHashtagTap(self.didTapHashtag)
            label.handleMentionTap(self.didTapMention)

            label.handleURLTap(self.didTapUrl)
        }

        if let user = TreatMe.data.idUsers[message.userId] {
            cell.setUser(user)
        }

        cell.timestampLabel.text = message.time.asFriendlyTime()

        cell.transform = self.collectionView.transform

        return cell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let message = self.messages[indexPath.row]

        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

        if let user = TreatMe.data.idUsers[message.userId] where user != TreatMe.data.authenticatedUser {
            let sendMessage = UIAlertAction(title: "Message @\(user.username)", style: .Default) { alert in
                self.goToChannelForUser(user)
            }
            menu.addAction(sendMessage)
        }

        let copyText = UIAlertAction(title: "Copy Text", style: .Default) { alert in
            let pasteBoard = UIPasteboard.generalPasteboard()
            pasteBoard.string = message.content
        }
        menu.addAction(copyText)

        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { _ in }
        menu.addAction(cancel)

        self.presentViewController(menu, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - AutoComplete
    override func didChangeAutoCompletionPrefix(prefix: String, andWord word: String) {
        var source: [String]
        if prefix == "#" {
            source = Array(self.tagChannels.keys)
        }
        else if prefix == "@" {
            source = self.userHandles
        } else {
            self.searchResult.removeAll()
            self.showAutoCompletionView(false)
            return
        }

        if !word.isEmpty {
            self.searchResult = source.filter { $0.localizedCaseInsensitiveContainsString(word) }.sort() { $0.localizedCaseInsensitiveCompare($1) == .OrderedAscending }
        } else {
            self.searchResult.removeAll()
        }

        self.showAutoCompletionView(!self.searchResult.isEmpty)
    }

    override func heightForAutoCompletionView() -> CGFloat {
        return self.autocompleteCellHeight * CGFloat(self.searchResult.count)
    }

    // MARK: - UITableViewDataSource

    override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return .Plain
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResult.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCellWithIdentifier(self.autocompleteCellIdentifier) {
            cell.textLabel!.text = self.searchResult[indexPath.row]
            return cell
        }

        return UITableViewCell()
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.autocompleteCellHeight
    }

    // MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.autoCompletionView == tableView {
            let completeResult = self.searchResult[indexPath.row] + " "
            self.acceptAutoCompletionWithString(completeResult)
            self.searchResult.removeAll()
        }
    }

}

extension ChatViewController: MessageCollectionViewDelegateLayout {
    func collectionView(collectionView: UICollectionView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        let text = self.messages[indexPath.row].content

        let maxWidth = collectionView.frame.width - MessageCell.horizontalPad

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraphStyle.alignment = NSTextAlignment.Left

        let attributes = [NSFontAttributeName: MessageCell.messageTextFont, NSParagraphStyleAttributeName: paragraphStyle]

        let options = NSStringDrawingOptions.UsesLineFragmentOrigin
        let boundingRect = text.boundingRectWithSize(CGSizeMake(maxWidth, 0), options: options, attributes: attributes, context: nil)

        let height = max(boundingRect.height + MessageCell.nonTextHeight, MessageCell.minHeight)

        return height
    }

}

