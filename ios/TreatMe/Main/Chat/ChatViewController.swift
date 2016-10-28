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
                if let groupId = channel.groupId, let group = TreatMe.data.idGroups[groupId] {
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
                channelMessages.insert(pending, at: 0)
            }
            return channelMessages
        }
    }

    var pendingMessage: Message?

    var userHandles: [String] {
        get {
            let users = self.searchableGroups.flatMap { TreatMe.data.groupUsers[$0] }.joined()
            return users.map { $0.username }
        }
    }

    var tagChannels: [String: Channel] {
        get {
            let channels = self.searchableGroups.flatMap { TreatMe.data.groupChannels[$0] }.joined()
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
        control.addTarget(self, action: #selector(refreshMessages), for: .valueChanged)
        return control
    }()

    lazy var collectionBackground: UIView = { [unowned self] in
        let view = UIView(frame: (self.collectionView?.frame)!)
        view.backgroundColor = UIColor.white

        let message = UILabel(frame: CGRect(x: 0, y: 10, width: self.view.frame.width, height: 20))
        message.text = "All messages loaded!"
        message.font = UIFont.italicSystemFont(ofSize: 11.0)
        message.textColor = UIColor.darkGray
        message.textAlignment = .center

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

        NotificationCenter.default.addObserver(self, selector: #selector(switchChannel), name: NSNotification.Name(rawValue: TreatMeNotifications.RefreshChat.rawValue), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(newMessage), name: NSNotification.Name(rawValue: TreatMeNotifications.NewMessage.rawValue), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
        if let channel = self.selectedChannel, let unread = TreatMe.data.channelUnread[channel] , unread > 0 {
            TreatMe.client.markChannelRead(channel)
        }
    }

    func newMessage(_ notification: Notification) {
        let channelId = (notification as NSNotification).userInfo?["channel"] as! String
        let messageId = (notification as NSNotification).userInfo?["message"] as! String
        let index = (notification as NSNotification).userInfo?["index"] as! Int

        if let channel = TreatMe.data.channels[channelId], let message = TreatMe.data.idMessages[messageId] {

            if channel == self.selectedChannel {
                let idxPath = IndexPath(item: index, section: 0)
                self.collectionView?.insertItems(at: [idxPath])
            } else {
                // See if the message was a user channel or contained the authenticated users handle
                // and show an alert

                if let user = TreatMe.data.idUsers[message.userId] {
                    if channel.groupId == nil {
                        Drop.down("New message from @\(user.username)", state: TMState.info, duration: 3.0) {
                            TreatMe.data.selectedChannelId = channel.id
                        }
                    } else {
                        if let authUser = TreatMe.data.authenticatedUser ,
                            message.content.contains("@\(authUser.username)") {
                            Drop.down("@\(user.username) mentioned you in #\(channel.displayName())", state: TMState.info, duration: 3.0) {
                                TreatMe.data.selectedChannelId = channel.id
                            }
                        }
                    }
                }
            }

        } else {
            // Somehow got a message for a channel we don't know about, so reload channels
            when(fulfilled: TreatMe.client.refreshUserChannels(), TreatMe.client.refreshGroups())
                .catch { _ in
                    Drop.down("Sorry, something went wrong.", state: TMState.error)
            }

        }

    }

    func refreshView() {
        self.title = self.selectedChannel?.displayName()
        self.titleView.channelLabel.text = self.title

        if let selected = self.selectedChannel, let user = selected.otherUser {
            self.titleView.setOnline(TreatMe.data.onlineUsers.contains(where: { $0.id == user.id }))
        } else {
            self.titleView.setOnline(false)
        }

        self.collectionView?.reloadData()
        self.view.setNeedsLayout()
    }

    func leftNavButtonPress() {
        self.dismissKeyboard(false)
        self.evo_drawerController?.toggleLeftDrawerSide(animated: true, completion: nil)
    }

    func rightNavButtonPress() {
        self.dismissKeyboard(false)
        let profile = ProfileViewController(user: TreatMe.data.authenticatedUser!)
        self.present(profile, animated: true, completion: nil)
    }

    func configureViews() {
        self.navigationItem.titleView = titleView
        self.title = self.selectedChannel?.displayName()
        self.titleView.channelLabel.text = self.title

        let menuImage = UIImage(named: "menu-icon")
        let leftDrawerButton = UIBarButtonItem(image: menuImage, style: .plain, target: self, action: #selector(leftNavButtonPress))
        leftDrawerButton.tintColor = UIColor.black
        self.navigationItem.setLeftBarButton(leftDrawerButton, animated: false)
        self.evo_drawerController?.maximumLeftDrawerWidth = 240

        let profileImage = UIImage(named: "profile-icon")
        let showProfileButton = UIBarButtonItem(image: profileImage, style: .plain, target: self, action: #selector(rightNavButtonPress))
        showProfileButton.tintColor = UIColor.black
        self.navigationItem.setRightBarButton(showProfileButton, animated: false)
        self.evo_drawerController?.maximumRightDrawerWidth = 240

        self.bounces = true
        self.isKeyboardPanningEnabled = false
        self.isInverted = true

        self.textView.placeholder = "Message"
        self.textView.placeholderColor = UIColor.lightGray

        self.leftButton.tintColor = UIColor.gray
        self.rightButton.setTitle("Send", for: UIControlState.normal)

        self.textInputbar.autoHideRightButton = true
        self.textInputbar.counterStyle = .none

        self.typingIndicatorView?.canResignByTouch = true

        let cellNib: UINib = UINib(nibName: "MessageCell", bundle: Bundle.main)
        self.collectionView?.register(cellNib, forCellWithReuseIdentifier: MessageCell.identifier)
        self.collectionView?.alwaysBounceVertical = true
        self.collectionView?.addSubview(self.refreshControl)
        self.collectionView?.backgroundView = self.collectionBackground
        self.collectionBackground.transform = (self.collectionView?.transform)!

        self.refreshControl.transform = (self.collectionView?.transform)!

        self.edgesForExtendedLayout = []
        self.navigationController?.navigationBar.barTintColor = UIColor.white

        self.autoCompletionView.register(UITableViewCell.self, forCellReuseIdentifier: self.autocompleteCellIdentifier)

        self.registerPrefixes(forAutoCompletion: ["@", "#"])
    }

    func refreshMessages(_ refreshControl: UIRefreshControl) {
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
            return Promise(value: true).asVoid()
        }

        self.loadingMessages = true
        return TreatMe.client.getChannelMessages(channel, lastMessage: self.messages.last).then { [unowned self] messages -> Void in

            TreatMe.data.insertMessages(messages, forChannel: channel, notify: false)

            if (messages.count < MESSAGE_LIMIT) {
                self.shouldLoadMessages = false
            }
        }.onError { _ in
            Drop.down("Uh oh, something went wrong. Try again in a sec.", state: TMState.error, duration: 1.0)
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

    override func didPressRightButton(_ sender: Any!) {
        // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
        textView.refreshFirstResponder()

        if self.canSendMessage {
            if let channel = self.selectedChannel, let text = self.textView.text {
                self.canSendMessage = false
                self.rightButton.isEnabled = false

                self.pendingMessage = Message(id: "pending", content: text, time: Date(), userId: TreatMe.data.authenticatedUser!.id, channelId: channel.id)
                self.collectionView?.reloadData()
                super.didPressRightButton(sender)

                TreatMe.client.sendMessage(text, toChannel: channel).then { message -> Void in
                    self.pendingMessage = nil
                    if let index = TreatMe.data.insertMessage(message, forChannel: channel, notify: false) {
                        let paths = (0...index).map { IndexPath(row: $0, section: 0) }
                        UIView.performWithoutAnimation {
                            self.collectionView?.reloadItems(at: paths)
                        }
                    }
                }.onError { _ in
                    Drop.down("Woops! Your message was not sent. Please try again.", state: TMState.error, duration: 5.0)
                    self.textView.text = self.pendingMessage?.content
                    self.pendingMessage = nil
                    self.collectionView?.reloadData()
                }.always {
                    self.canSendMessage = true
                    self.rightButton.isEnabled = true
                }
            }
        }

    }

    func didTapHashtag(_ tag: String) {
        if let channel = self.tagChannels[tag] , channel != self.selectedChannel {
            animateToChannel(channel)
        }
    }

    func didTapMention(_ mention: String) {
        if let user = TreatMe.data.users.first(where: { $0.username == mention }) , user != TreatMe.data.authenticatedUser {
            goToChannelForUser(user)
        }
    }

    func didTapUrl(_ url: URL) {
        let lowerString = url.absoluteString.lowercased()
        if lowerString.hasPrefix("http://") || lowerString.hasPrefix("https://") {
            UIApplication.shared.openURL(url)
        } else if let url = URL(string: "http://\(lowerString)"){
            UIApplication.shared.openURL(url)
        }
    }

    fileprivate func goToChannelForUser(_ user: User) {
        TreatMe.client.channelForUser(user).then { channel -> Void in
            self.animateToChannel(channel)
            }.catch { _ in
                Drop.down("Sorry, something went wrong.", state: TMState.error, duration: 5.0)
        }
    }

    fileprivate func animateToChannel(_ channel: Channel) {
        let blackView = UIView(frame: self.view.frame)
        blackView.backgroundColor = UIColor.white
        self.view.addSubview(blackView)

        UIView.animate(withDuration: 0.25, animations: {
            TreatMe.data.selectedChannelId = channel.id
            blackView.alpha = 0.0
            }, completion: { finished in
                blackView.removeFromSuperview()
        })
    }

    // MARK: - UICollectionViewDataSource

    override class func collectionViewLayout(for decoder: NSCoder) -> UICollectionViewLayout {
        let layout = MessageCollectionViewLayout()
        return layout
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // If the item being requested is the last one, load more messages
        if self.shouldLoadMessages && (indexPath as NSIndexPath).row >= self.messages.count - loadMoreMessagesThreshold {
            self.loadMessages().then { [weak self] _ -> Void in
                self?.refreshView()
            }
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageCell.identifier, for: indexPath) as! MessageCell

        let message = self.messages[(indexPath as NSIndexPath).row]

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

        cell.transform = (self.collectionView?.transform)!

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let message = self.messages[(indexPath as NSIndexPath).row]

        let menu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if let user = TreatMe.data.idUsers[message.userId] , user != TreatMe.data.authenticatedUser {
            let sendMessage = UIAlertAction(title: "Message @\(user.username)", style: .default) { alert in
                self.goToChannelForUser(user)
            }
            menu.addAction(sendMessage)
        }

        let copyText = UIAlertAction(title: "Copy Text", style: .default) { alert in
            let pasteBoard = UIPasteboard.general
            pasteBoard.string = message.content
        }
        menu.addAction(copyText)

        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        menu.addAction(cancel)

        self.present(menu, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - AutoComplete
    override func didChangeAutoCompletionPrefix(_ prefix: String, andWord word: String) {
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
            self.searchResult = source.filter { $0.localizedCaseInsensitiveContains(word) }.sorted() { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        } else {
            self.searchResult.removeAll()
        }

        self.showAutoCompletionView(!self.searchResult.isEmpty)
    }

    override func heightForAutoCompletionView() -> CGFloat {
        return self.autocompleteCellHeight * CGFloat(self.searchResult.count)
    }

    // MARK: - UITableViewDataSource

    override class func tableViewStyle(for decoder: NSCoder) -> UITableViewStyle {
        return .plain
    }

    override func numberOfSections(in: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResult.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: self.autocompleteCellIdentifier) {
            cell.textLabel!.text = self.searchResult[(indexPath as NSIndexPath).row]
            return cell
        }

        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.autocompleteCellHeight
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.autoCompletionView == tableView {
            let completeResult = self.searchResult[(indexPath as NSIndexPath).row] + " "
            self.acceptAutoCompletion(with: completeResult)
            self.searchResult.removeAll()
        }
    }

}

extension ChatViewController: MessageCollectionViewDelegateLayout {
    func collectionView(_ collectionView: UICollectionView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {

        let text = self.messages[(indexPath as NSIndexPath).row].content

        let maxWidth = collectionView.frame.width - MessageCell.horizontalPad

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraphStyle.alignment = NSTextAlignment.left

        let attributes = [NSFontAttributeName: MessageCell.messageTextFont, NSParagraphStyleAttributeName: paragraphStyle]

        let options = NSStringDrawingOptions.usesLineFragmentOrigin
        let boundingRect = text.boundingRect(with: CGSize(width: maxWidth, height: 0), options: options, attributes: attributes, context: nil)

        let height = max(boundingRect.height + MessageCell.nonTextHeight, MessageCell.minHeight)

        return height
    }

}

