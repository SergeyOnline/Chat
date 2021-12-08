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
	
	internal enum Constants {
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
	}
	
	internal enum LocalizeKeys {
		static let messageInputFieldPlaceholder = "messageInputFieldPlaceholder"
		static let headerDateTitle = "headerDateTitle"
	}
	
	private var isKeyboardHidden = true
	private var isPlaceholderShown = true
	
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
	
	var presenter: IConversationMessagesPresenter?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	// MARK: - Actions
	@objc func addButtonAction(_ sender: UIButton) {
		presenter?.addButtonAction()
	}
	@objc func sendButtonAction(_ sender: UIButton) {
		if messageInputField.text.isEmpty || isPlaceholderShown { return }
		presenter?.sendButtonAction(forMessage: messageInputField.text)
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
	
	@objc func keyboardWillShow(_ sender: NSNotification) {
		if isKeyboardHidden {
			isKeyboardHidden = false
			guard let info = sender.userInfo else { return }
			guard let rect = info[Constants.keyboardNotificatoinKey] as? CGRect else { return }
			let height = rect.height
			let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - height)
			view.frame = frame
		}
		guard let messages = presenter?.getFetchedMessagesCount() else { return }
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
			guard let messages = presenter?.getFetchedMessagesCount() else { return }
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
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - Private functions
	
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
	
		view.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		
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
		titleLabel.text = presenter?.getChannelName()
		titleLabel.sizeToFit()
		titleLabel.textAlignment = .center
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.textColor = NavigationBarAppearance.elementsColor.uiColor()
		let channelImageView = UserImageView(labelTitle: presenter?.getChannelTitle() ?? "", labelfontSize: Constants.userImageViewLabelfontSize)
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
		guard let count = presenter?.getMessagesCount() else { return }
		let cellNumber = count - 1
		let indexPath = IndexPath(row: cellNumber, section: 0)
		DispatchQueue.main.async {
			if count > 1 {
				self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
			}
		}
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

extension ConversationViewController: IConversationMessagesView {
	
	func setInputTextFieldForAddAction(text: String) {
		messageInputField.becomeFirstResponder()
		messageInputField.text = text
	}

	func presentImagePickerVC(viewController: UIViewController) {
		present(viewController, animated: true, completion: nil)
	}
	
	func tableViewBeginUpdate() {
		tableView.beginUpdates()
	}
	
	func tableViewEndUpdate() {
		tableView.endUpdates()
	}
	
	func tableViewInsertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
		tableView.insertRows(at: indexPaths, with: animation)
	}
	
	func tableViewDeleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
		tableView.deleteRows(at: indexPaths, with: animation)
	}
	
	func tableViewReloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
		tableView.reloadRows(at: indexPaths, with: animation)
	}
	
	func setViewFrame(_ frame: CGRect) {
		view.frame = frame
	}
}
