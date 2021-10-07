//
//  ConversationViewController.swift
//  Chat
//
//  Created by Сергей on 05.10.2021.
//

import UIKit

final class ConversationViewController: UIViewController {

	var user: User
	weak var delegate: ConversationsListViewControllerDelegate?
	var tableView: UITableView!
	var messageInputField: UITextView!
	var textinputView: UIView!
	
	
	private enum Constants {
		static let inputID = "input"
		static let outputID = "output"
		static let maxHeightMessageInput = 120.0
		static let minHeightMessageInput = 32.0
		static let keyboardNotificatoinKey = "UIKeyboardFrameEndUserInfoKey"
		static let messageInputFieldCornerRadius = 8.0
		static let sendButtonImageName = "Send"
		static let viewBackgroundColor = UIColor(red: 239/255, green: 239/255, blue: 245/255, alpha: 1)
	}
	
	private var isKeyboerdHidden = true
	
	private var tapGesture: UITapGestureRecognizer!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		view.backgroundColor = (traitCollection.userInterfaceStyle == .dark) ? .darkGray.withAlphaComponent(0.4) : Constants.viewBackgroundColor
		
		navigationItem.title = user.fullName
		navigationController?.navigationBar.tintColor = (traitCollection.userInterfaceStyle == .light) ? .black : .white

		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil);
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil);
	
		tapGesture =  UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:)))
		view.addGestureRecognizer(tapGesture)
		
		textinputView = UIView()
		textinputView.backgroundColor = view.backgroundColor
		textinputView.translatesAutoresizingMaskIntoConstraints = false
		
		messageInputField = UITextView()
		messageInputField.layer.cornerRadius = Constants.messageInputFieldCornerRadius
		messageInputField.translatesAutoresizingMaskIntoConstraints = false
		messageInputField.isScrollEnabled = false
		messageInputField.delegate = self
		resizeTextViewToFitText()
		
		let addButton = UIButton(type: .contactAdd)
		addButton.translatesAutoresizingMaskIntoConstraints = false
		addButton.addTarget(self, action: #selector(addButtonAction(_:)), for: .touchUpInside)
		addButton.translatesAutoresizingMaskIntoConstraints = false
		
		textinputView.addSubview(addButton)
		addButton.leftAnchor.constraint(equalTo: textinputView.leftAnchor, constant: 12).isActive = true
		addButton.bottomAnchor.constraint(equalTo: textinputView.bottomAnchor, constant: -5).isActive = true
		addButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
		
		let sendButton = UIButton(type: .roundedRect)
		let image = UIImage(named: Constants.sendButtonImageName)
		sendButton.setImage(image, for: .normal)

		sendButton.translatesAutoresizingMaskIntoConstraints = false
		sendButton.addTarget(self, action: #selector(sendButtonAction(_:)), for: .touchUpInside)
		sendButton.translatesAutoresizingMaskIntoConstraints = false
		
		textinputView.addSubview(sendButton)
		sendButton.rightAnchor.constraint(equalTo: textinputView.rightAnchor, constant: -12).isActive = true
		sendButton.bottomAnchor.constraint(equalTo: textinputView.bottomAnchor, constant: -5).isActive = true
		sendButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
		sendButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
		
		
		textinputView.addSubview(messageInputField)
		messageInputField.centerYAnchor.constraint(equalTo: textinputView.centerYAnchor).isActive = true
		messageInputField.leftAnchor.constraint(equalTo: textinputView.leftAnchor, constant: 50).isActive = true
		messageInputField.rightAnchor.constraint(equalTo: textinputView.rightAnchor, constant: -60).isActive = true
		
		
		self.view.addSubview(textinputView)
		textinputView.heightAnchor.constraint(equalTo: messageInputField.heightAnchor, constant: 20).isActive = true
		textinputView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
		textinputView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
		textinputView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
		

		tableView = UITableView(frame: CGRect.zero, style: .plain)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(MessageCell.self, forCellReuseIdentifier: Constants.inputID)
		tableView.register(MessageCell.self, forCellReuseIdentifier: Constants.outputID)
		tableView.separatorStyle = .none
		tableView.translatesAutoresizingMaskIntoConstraints = false
		
		self.view.addSubview(tableView)
		
		tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
		tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
		tableView.bottomAnchor.constraint(equalTo: textinputView.topAnchor).isActive = true
		
		if user.messages != nil {
			let cellNumber = user.messages!.count - 1
			let indexPath = IndexPath(row: cellNumber, section: 0)
			DispatchQueue.main.async {
				self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
			}
		}
    }
	
	//MARK: - Actions
	@objc func addButtonAction(_ sender: UIButton) {
		//TODO: - Add
		print("TO DO")
	}
	
	@objc func sendButtonAction(_ sender: UIButton) {
//		messageInputField.resignFirstResponder()
		if messageInputField.text.isEmpty {
			return
		}
		let newMessage = Message(body: messageInputField.text, date: Date(), unread: false, ownerID: 0)
		if user.messages == nil {
			user.messages = [newMessage]
		} else {
			user.messages!.append(newMessage)
		}
		messageInputField.text = ""
		resizeTextViewToFitText()
		self.tableView.reloadData()
		DispatchQueue.main.async {
			let cellNumber = self.user.messages!.count - 1
			let indexPath = IndexPath(row: cellNumber, section: 0)
			self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
		}
		//TODO: - Send request to server!
	}
	
	@objc func tapGestureAction(_ sender: UITapGestureRecognizer) {
		let location = sender.location(in: view)
		if !textinputView.point(inside: location, with: nil) {
			if messageInputField.isFirstResponder {
				messageInputField.resignFirstResponder()
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		delegate?.changeMessagesForUserWhithID(user.id, to: user.messages)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if user.messages != nil {
			for i in 0..<user.messages!.count {
				user.messages![i].unread = false
			}
		}
	}
    
	init(user: User) {
		self.user = user
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func keyboardWillShow(_ sender: NSNotification) {
		if isKeyboerdHidden {
			isKeyboerdHidden = false
			guard let info = sender.userInfo else { return }
			let height = (info[Constants.keyboardNotificatoinKey] as! CGRect).height
			let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - height)
			view.frame = frame
		}
		if user.messages != nil {
			DispatchQueue.main.async {
				let cellNumber = self.user.messages!.count - 1
				let indexPath = IndexPath(row: cellNumber, section: 0)
				self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
			}
		}
	}
	
	@objc func keyboardWillHide(_ sender: NSNotification) {
		if !isKeyboerdHidden {
			isKeyboerdHidden = true
			guard let info = sender.userInfo else { return }
			let height = (info[Constants.keyboardNotificatoinKey] as! CGRect).height
			let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + height)
			self.view.frame = frame
			if user.messages != nil {
				DispatchQueue.main.async {
					let cellNumber = self.user.messages!.count - 1
					let indexPath = IndexPath(row: cellNumber, section: 0)
					self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
				}
			}
		}
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	//MARK: - Private functions
	private func resizeTextViewToFitText() {
		let size = CGSize(width: messageInputField.frame.width, height: .infinity)
		let expectedSize = messageInputField.sizeThatFits(size)
		for constraint in messageInputField.constraints {
			if constraint.firstAttribute == .height {
				constraint.constant = max(min(expectedSize.height, Constants.maxHeightMessageInput), Constants.minHeightMessageInput)
			}
		}
		if expectedSize.height > Constants.maxHeightMessageInput {
			messageInputField.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.maxHeightMessageInput).isActive = true
			messageInputField.isScrollEnabled = true

		} else {
			messageInputField.isScrollEnabled = false
		}
		UIView.animate(withDuration: 0.1) {
			self.view.layoutIfNeeded()
		}
	}

}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return user.messages?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	
		let id = (user.messages?[indexPath.row].ownerID != 0) ? Constants.inputID : Constants.outputID
		let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! MessageCell
		cell.messageText = user.messages?[indexPath.row].body ?? ""
		cell.owherID = user.messages?[indexPath.row].ownerID ?? 0

		return cell
	}
	
}

extension ConversationViewController: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		resizeTextViewToFitText()
	}
}
