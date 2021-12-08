//
//  ConversationViewController.swift
//  Chat
//
//  Created by Сергей on 05.10.2021.
//

import UIKit
import Firebase
import CoreData

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
		static let headerDateTitle = "headerDateTitle"
	}
	private enum DateFormat {
		static let hourAndMinute = "HH:mm"
		static let dayAndMonth = "dd MMMM"
	}
	
	private let ownerID = UIDevice.current.identifierForVendor?.uuidString ?? ""
	private var ownerName = Owner().fullName
	
	private lazy var db = Firestore.firestore()
	private lazy var referenceChannel = db.collection(Constants.channelsDBCollection)
	private lazy var referenceMessages: CollectionReference = {
		guard let channelIdentifier = channel?.identifier else { fatalError() }
		return referenceChannel.document(channelIdentifier).collection(Constants.messagesDBCollection)
	}()
	private var listener: ListenerRegistration?
	private lazy var fetchResultController: NSFetchedResultsController<DBMessage> = {
		let request: NSFetchRequest<DBMessage> = DBMessage.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "created", ascending: true)
		request.fetchBatchSize = 20
		request.sortDescriptors = [sortDescriptor]
		let predicate = NSPredicate(format: "channel.identifier == %@", (channel?.identifier ?? ""))
		request.predicate = predicate
		let controller = NSFetchedResultsController(fetchRequest: request,
													managedObjectContext: dataManager.persistentContainer.viewContext,
													sectionNameKeyPath: nil,
													cacheName: "messages")
		controller.delegate = self
		do {
			try controller.performFetch()
		} catch {
			fatalError("Failed to fetch entities: \(error)")
		}
		return controller
	}()
	var channel: DBChannel?
	private var isKeyboardHidden = true
	private var tailsArray: [Bool] = []
	private var isPlaceholderShown = true
	private let dataManager = DataManager.shared
	
	// MARK: - UI
	var tableView = UITableView(frame: CGRect.zero, style: .plain)
	var messageInputField: UITextView = {
		let textView = UITextView()
		textView.backgroundColor = TableViewCellAppearance.backgroundColor.uiColor()
		return textView
	}()
	var textinputView = UIView()
	private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:)))
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
		if let id = channel?.identifier {
			dataManager.logMessagesContent(forChannelId: id)
		}
	}
	
	// MARK: - Actions
	@objc func addButtonAction(_ sender: UIButton) {
		// TODO: - Add
		print("TO DO")
	}
	@objc func sendButtonAction(_ sender: UIButton) {
		if messageInputField.text.isEmpty || isPlaceholderShown { return }
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
	
	init(channel: DBChannel) {
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
		guard let messages = fetchResultController.fetchedObjects?.count else { return }
		DispatchQueue.main.async {
			let cellNumber = messages - 1
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
			guard let messages = fetchResultController.fetchedObjects?.count else { return }
			DispatchQueue.main.async {
				let cellNumber = messages - 1
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
		listener?.remove()
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - Private functions
	func getMessage() {
		listener = referenceMessages.addSnapshotListener { [weak self] querySnapshot, error in
			if let error = error {
				print("Error getting documents: \(error)")
				return
			}
			guard let snapshot = querySnapshot else { return }
			guard let id = self?.channel?.identifier else { return }
			var messages: [DocumentChange] = []
			snapshot.documentChanges.forEach { message in
				if message.type == .added {
					if !message.document.metadata.isFromCache {
						messages.append(message)
					}
				}
				// MARK: - modify message if needed
				// if message.type == .modified {}
				// MARK: - remove message if needed
				// if message.type == .removed {}
			}
			self?.dataManager.saveMessage(messages, forChannelId: id, completion: {
				DispatchQueue.main.async {
					self?.scrollTableViewToEnd()
				}
			})
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
			case .success(let owner): self?.ownerName = owner.fullName
			case .failure: self?.ownerName = Owner().fullName
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
		guard let channelName = name else { return result }
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
		messageInputField.font = UIFont.systemFont(ofSize: 16)
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
		if #available(iOS 14.0, *) {
			sendButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
			sendButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
		} else {
			sendButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
			sendButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
		}
	}
	
	private func setupTextinputViewConstraints() {
		textinputView.heightAnchor.constraint(equalTo: messageInputField.heightAnchor, constant: 40).isActive = true
		textinputView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
		textinputView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
		textinputView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
	}
	
	func scrollTableViewToEnd() {
		guard let id = channel?.identifier else { return }
		let count = dataManager.messagesCount(forChannel: id)
		let cellNumber = count - 1
		let indexPath = IndexPath(row: cellNumber, section: 0)
		DispatchQueue.main.async {
			if count > 1 {
				self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
			}
		}
	}
	
	private func stringFromDate(_ date: Date?, whithFormat format: String) -> String {
		guard let d = date else { return "" }
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: d)
	}
	
	private func calculateHeaderForMessagesOfOneDay(forCellIndex indexPath: IndexPath) -> String {
		let message = fetchResultController.object(at: indexPath)
		let prevMessage: DBMessage
		if indexPath.row != 0 {
			let prevIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
			prevMessage = fetchResultController.object(at: prevIndexPath)
		} else {
			prevMessage = message
		}
		var result = ""
		let calendar = Calendar(identifier: .gregorian)
		if indexPath.row == 0 {
			if let currentMessageDate = message.created {
				if calendar.startOfDay(for: currentMessageDate) == calendar.startOfDay(for: Date()) {
					result = NSLocalizedString(LocalizeKeys.headerDateTitle, comment: "")
				} else {
					result = stringFromDate(currentMessageDate, whithFormat: DateFormat.dayAndMonth)
				}
			}
		} else {
			if let currentMessageDate = message.created, let previosMessageDate = prevMessage.created {
				let beginningDayCurent = calendar.startOfDay(for: currentMessageDate)
				let beginningDayPrevios = calendar.startOfDay(for: previosMessageDate)
				if beginningDayCurent != beginningDayPrevios {
					if beginningDayCurent == calendar.startOfDay(for: Date()) {
						result = NSLocalizedString(LocalizeKeys.headerDateTitle, comment: "")
					} else {
						result = stringFromDate(currentMessageDate, whithFormat: DateFormat.dayAndMonth)
					}
				}
			}
		}
		return result
	}
	
	private func configureCell(_ cell: MessageCell, atIndexPath indexPath: IndexPath) {
		let index = indexPath.row
		guard let messages = fetchResultController.fetchedObjects else { return }
		tailsArray = [true]
		if messages.count >= 1 {
			for i in 1..<messages.count {
				if i == 0 {	continue }
				tailsArray.append(true)
				if messages[i].senderId == messages[i - 1].senderId {
					tailsArray[i - 1] = false
				}
			}
		}
		if index < tailsArray.count {
			cell.isTailNeed = tailsArray[index]
		}
		let message = fetchResultController.object(at: indexPath)
		let name = message.senderName ?? ""
		if index == 0 {
			cell.nameLabel.text = name.isEmpty ? "Unknown" : name
		} else {
			cell.nameLabel.text = (index < tailsArray.count && tailsArray[index - 1] == true) ? (name.isEmpty ? "Unknown" : name) : ""
		}
		cell.newDayLabel.text = calculateHeaderForMessagesOfOneDay(forCellIndex: indexPath)
		cell.messageText = message.content ?? ""
		cell.date = stringFromDate(message.created ?? nil, whithFormat: DateFormat.hourAndMinute)
	}
	
}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return fetchResultController.sections?.count ?? 0
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let sections = self.fetchResultController.sections else {
			fatalError("No sections in fetchedResultsController")
		}
		let sectionInfo = sections[section]
		return sectionInfo.numberOfObjects
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let message = fetchResultController.object(at: indexPath)
		let id = (message.senderId != ownerID) ? Constants.inputID : Constants.outputID
		guard let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as? MessageCell else {
			return UITableViewCell()
		}
		configureCell(cell, atIndexPath: indexPath)
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
