//
//  ConversationViewController.swift
//  Chat
//
//  Created by Сергей on 05.10.2021.
//

import UIKit
import Firebase

final class ConversationViewController: UIViewController {
	
	private enum Constants {
		static let inputID = "input"
		static let outputID = "output"
		static let maxHeightMessageInput = 120.0
		static let minHeightMessageInput = 32.0
		static let keyboardNotificatoinKey = "UIKeyboardFrameEndUserInfoKey"
		static let messageInputFieldCornerRadius = 8.0
		static let sendButtonImageName = "Send"
		static let sendButtonSystemImageName = "paperplane.fill"
		static let userImageViewCornerRadius = 18.0
		static let userImageViewWidth = 36.0
		static let userImageViewHeight = 36.0
		static let userImageViewLabelfontSize = 18.0
		static let titleFont = UIFont.boldSystemFont(ofSize: 16)
		static let channelsDBCollection = "channels"
		static let messagesDBCollection = "messages"
		static let messageKeyContent = "content"
		static let messageKeyCreated = "created"
		static let messageKeySenderId = "senderId"
		static let messageKeySenderName = "senderName"
	}
	
	private enum LocalizeKeys {
		static let messageInputFieldPlaceholder = "messageInputFieldPlaceholder"
	}
	
	private let ownerID = UIDevice.current.identifierForVendor?.uuidString ?? ""
	private var ownerName = Owner().fullName
	
	private lazy var db = Firestore.firestore()
	private lazy var referenceChannel = db.collection(Constants.channelsDBCollection)
	private lazy var referenceMessages: CollectionReference = {
		guard let channelIdentifier = channel?.identifier else { fatalError() }
		return referenceChannel.document(channelIdentifier).collection(Constants.messagesDBCollection)
	}()
	
	// MARK: - Model
//	var user: User
	var channel: Channel?
	var messages: [ChannelMessage]?
	
	// MARK: - UI
	var tableView: UITableView = {
		let table = UITableView(frame: CGRect.zero, style: .plain)
		return table
	}()
	
	var messageInputField: UITextView = {
		let textView = UITextView()
		textView.backgroundColor = TableViewCellAppearance.backgroundColor.uiColor()
		return textView
	}()
	
	var textinputView: UIView = {
		let view = UIView()
		return view
	}()
	
	private var isKeyboardHidden = true
	private var tailsArray: [Bool] = []
	private var isPlaceholderShown = true
	
	private lazy var tapGesture: UITapGestureRecognizer = {
		let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:)))
		return gesture
	}()
	
	private lazy var addButton: UIButton = {
		let button = UIButton(type: .contactAdd)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(addButtonAction(_:)), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private lazy var sendButton: UIButton = {
		let button = UIButton(type: .roundedRect)
		var image: UIImage?
		if #available(iOS 13.0, *) {
			image = UIImage(systemName: Constants.sendButtonSystemImageName)
		} else {
			image = UIImage(named: Constants.sendButtonImageName)
		}
		button.setImage(image, for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(sendButtonAction(_:)), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	// MARK: - Actions
	@objc func addButtonAction(_ sender: UIButton) {
		// TODO: - Add
		print("TO DO")
	}
	
	@objc func sendButtonAction(_ sender: UIButton) {
		if messageInputField.text.isEmpty || isPlaceholderShown {
			return
		}
		let newMessage = ChannelMessage(content: messageInputField.text, created: Date(), senderId: ownerID, senderName: ownerName)
		referenceMessages.addDocument(data: newMessage.toDict)
		
		messageInputField.text = ""
		resizeTextViewToFitText()
	}
	
	@objc func tapGestureAction(_ sender: UITapGestureRecognizer) {
		let location = sender.location(in: view)
		if !textinputView.point(inside: location, with: nil) {
			if messageInputField.isFirstResponder {
				messageInputField.resignFirstResponder()
			}
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
//		if user.messages != nil {
//			for i in 0..<user.messages!.count {
//				user.messages![i].unread = false
//			}
//		}
	}
	
//	init(user: User) {
//		self.user = user
//		super.init(nibName: nil, bundle: nil)
//	}
	
	init(channel: Channel) {
		self.channel = channel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func keyboardWillShow(_ sender: NSNotification) {
		if isKeyboardHidden {
			isKeyboardHidden = false
			guard let info = sender.userInfo else { return }
			guard let rect = info[Constants.keyboardNotificatoinKey] as? CGRect else { return }
			let height = rect.height
			let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - height)
			view.frame = frame
		}
		guard let messages = messages else { return }
		DispatchQueue.main.async {
			let cellNumber = messages.count - 1
			if cellNumber <= 0 { return }
			let indexPath = IndexPath(row: cellNumber, section: 0)
			self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
		}
	}
	
	@objc func keyboardWillHide(_ sender: NSNotification) {
		if !isKeyboardHidden {
			isKeyboardHidden = true
			guard let info = sender.userInfo else { return }
			guard let rect = info[Constants.keyboardNotificatoinKey] as? CGRect else { return }
			let height = rect.height
			let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + height)
			self.view.frame = frame
			guard let messages = messages else { return }
			DispatchQueue.main.async {
				let cellNumber = messages.count - 1
				if cellNumber <= 0 { return }
				let indexPath = IndexPath(row: cellNumber, section: 0)
				self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
			}
		}
	}
	
	@objc func appWillResignActive(_ sender: NSNotification) {
		messageInputField.endEditing(true)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - Private functions
	func getMessage() {
		referenceMessages.addSnapshotListener { [weak self] querySnapshot, error in
			var messages: [ChannelMessage] = []
			if let error = error {
				print("Error getting documents: \(error)")
				return
			}
			if let documents = querySnapshot?.documents {
				for document in documents {
					let data = document.data()
					let content: String = (data[Constants.messageKeyContent] as? String) ?? ""
					let created: Date = (data[Constants.messageKeyCreated] as? Timestamp)?.dateValue() ?? Date()
					let senderId: String = (data[Constants.messageKeySenderId] as? String) ?? ""
					let senderName: String = (data[Constants.messageKeySenderName] as? String) ?? ""
					let message = ChannelMessage(content: content, created: created, senderId: senderId, senderName: senderName)
					messages.append(message)
				}
			}
			DispatchQueue.main.async {
				self?.tailsArray = [true]
				messages = messages.sorted(by: { $0.created < $1.created })
				self?.messages = messages
				if messages.count >= 1 {
					for i in 1..<messages.count {
						if i == 0 {	continue }
						self?.tailsArray.append(true)
						if messages[i].senderId == messages[i - 1].senderId {
							self?.tailsArray[i - 1] = false
						}
					}
				}
				self?.tableView.reloadData()
				self?.scrollTableViewToEnd()
			}
		}
	}
	
	private func resizeTextViewToFitText() {
		let size = CGSize(width: messageInputField.frame.width, height: .infinity)
		let expectedSize = messageInputField.sizeThatFits(size)
		for constraint in messageInputField.constraints where constraint.firstAttribute == .height {
			constraint.constant = max(min(expectedSize.height, Constants.maxHeightMessageInput), Constants.minHeightMessageInput)
		}
		if expectedSize.height > Constants.maxHeightMessageInput {
			messageInputField.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.maxHeightMessageInput).isActive = true
			messageInputField.isScrollEnabled = true
			
		} else {
			messageInputField.isScrollEnabled = false
		}
		view.layoutIfNeeded()
	}
	
	private func setup() {
		
		let userProfileHandler = GCDUserProfileInfoHandler()
		userProfileHandler.loadOwnerInfo { [weak self] in
			switch $0 {
			case .success(let owner):
				self?.ownerName = owner.fullName
			case .failure:
				self?.ownerName = Owner().fullName
			}
		}
		
		view.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		
		getMessage()
		
		setupNavigationBar()
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)
		
		view.addGestureRecognizer(tapGesture)
		
		textinputView.backgroundColor = TableViewAppearance.backgroundColor.uiColor()
		textinputView.translatesAutoresizingMaskIntoConstraints = false
		
		setupMessageInputField()
		
		textinputView.addSubview(addButton)
		setupAddButtonConstraints()
		
		textinputView.addSubview(sendButton)
		setupSendButtonConstraints()
		
		textinputView.addSubview(messageInputField)
		setupMessageInputFieldConstraints()
		
		view.addSubview(textinputView)
		setupTextinputViewConstraints()
		
		setupTableView()
		view.addSubview(tableView)
		setupTableViewConstraints()
		
		scrollTableViewToEnd()
	}
	
	private func setupNavigationBar() {
		
		navigationController?.navigationBar.barTintColor = NavigationBarAppearance.backgroundColor.uiColor()
		navigationController?.navigationBar.tintColor = NavigationBarAppearance.elementsColor.uiColor()
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key(rawValue:
																							NSAttributedString.Key.foregroundColor.rawValue):
																	NavigationBarAppearance.elementsColor.uiColor()]
		
		let navigationTitleView = UIView()
		if let frame = navigationController?.navigationBar.frame {
			navigationTitleView.frame = frame
		}
		let titleLabel = UILabel()
		titleLabel.font = Constants.titleFont
		titleLabel.text = channel?.name
		titleLabel.sizeToFit()
		titleLabel.textAlignment = .center
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.textColor = NavigationBarAppearance.elementsColor.uiColor()
		let channelImageView = UserImageView(labelTitle: getChannelTitleForName(channel?.name), labelfontSize: Constants.userImageViewLabelfontSize)
		channelImageView.layer.cornerRadius = Constants.userImageViewCornerRadius
		channelImageView.translatesAutoresizingMaskIntoConstraints = false
		navigationTitleView.addSubview(channelImageView)
		navigationTitleView.addSubview(titleLabel)
		
		navigationItem.titleView = navigationTitleView
		
		titleLabel.centerYAnchor.constraint(equalTo: navigationTitleView.centerYAnchor).isActive = true
		titleLabel.centerXAnchor.constraint(equalTo: navigationTitleView.centerXAnchor).isActive = true
		channelImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
		channelImageView.rightAnchor.constraint(equalTo: titleLabel.leftAnchor, constant: -10).isActive = true
		channelImageView.heightAnchor.constraint(equalToConstant: Constants.userImageViewHeight).isActive = true
		channelImageView.widthAnchor.constraint(equalToConstant: Constants.userImageViewWidth).isActive = true
	}
	
	private func getChannelTitleForName(_ name: String?) -> String {
		var result = ""
		guard let channelName = name else {return result}
		if channelName.isEmpty { return result }
		let arr = channelName.components(separatedBy: " ")
		result.append(arr[0].first ?? " ")
		if arr.count > 1 {
			result.append(arr[1].first ?? " ")
		}
		return result.uppercased()
	}
	
	private func setupMessageInputField() {
		messageInputField.layer.cornerRadius = Constants.messageInputFieldCornerRadius
		messageInputField.translatesAutoresizingMaskIntoConstraints = false
		messageInputField.isScrollEnabled = false
		messageInputField.delegate = self
		messageInputField.text = NSLocalizedString(LocalizeKeys.messageInputFieldPlaceholder, comment: "")
		messageInputField.textColor = .lightGray
		resizeTextViewToFitText()
	}
	
	private func setupMessageInputFieldConstraints() {
		messageInputField.centerYAnchor.constraint(equalTo: textinputView.centerYAnchor, constant: -10).isActive = true
		messageInputField.leftAnchor.constraint(equalTo: textinputView.leftAnchor, constant: 50).isActive = true
		messageInputField.rightAnchor.constraint(equalTo: textinputView.rightAnchor, constant: -60).isActive = true
	}
	
	private func setupTableView() {
		tableView.backgroundColor = TableViewCellAppearance.backgroundColor.uiColor()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(MessageCell.self, forCellReuseIdentifier: Constants.inputID)
		tableView.register(MessageCell.self, forCellReuseIdentifier: Constants.outputID)
		tableView.separatorStyle = .none
		tableView.translatesAutoresizingMaskIntoConstraints = false
	}
	
	private func setupTableViewConstraints() {
		tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
		tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
		tableView.bottomAnchor.constraint(equalTo: textinputView.topAnchor).isActive = true
	}
	
	private func setupAddButtonConstraints() {
		addButton.leftAnchor.constraint(equalTo: textinputView.leftAnchor, constant: 12).isActive = true
		addButton.bottomAnchor.constraint(equalTo: textinputView.bottomAnchor, constant: -25).isActive = true
		addButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
	}
	
	private func setupSendButtonConstraints() {
		sendButton.rightAnchor.constraint(equalTo: textinputView.rightAnchor, constant: -12).isActive = true
		sendButton.bottomAnchor.constraint(equalTo: textinputView.bottomAnchor, constant: -25).isActive = true
		sendButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
		sendButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
	}
	
	private func setupTextinputViewConstraints() {
		textinputView.heightAnchor.constraint(equalTo: messageInputField.heightAnchor, constant: 40).isActive = true
		textinputView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
		textinputView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
		textinputView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
	}
	
	private func scrollTableViewToEnd() {
		guard let messages = messages else { return }
		let cellNumber = messages.count - 1
		let indexPath = IndexPath(row: cellNumber, section: 0)
		DispatchQueue.main.async {
			if !messages.isEmpty {
				self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
			}
		}
	}
	
}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return messages?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let index = indexPath.row
		let id = (messages?[index].senderId != ownerID) ? Constants.inputID : Constants.outputID
		guard let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as? MessageCell else {
			return UITableViewCell()
		}
		cell.isTailNeed = tailsArray[index]
		if index == 0 {
			cell.nameLabel.text = messages?[index].senderName ?? ""
		} else {
			cell.nameLabel.text = (tailsArray[index - 1] == true) ? messages?[index].senderName ?? "" : ""
		}
		cell.messageText = messages?[index].content ?? ""
		return cell
	}
	
}

extension ConversationViewController: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		resizeTextViewToFitText()
	}
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == .lightGray {
			textView.text = nil
			isPlaceholderShown = false
			textView.textColor = TableViewCellAppearance.textColor.uiColor()
		}
	}
	
	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty {
			textView.text = NSLocalizedString(LocalizeKeys.messageInputFieldPlaceholder, comment: "")
			isPlaceholderShown = true
			textView.textColor = .lightGray
		}
	}
}
