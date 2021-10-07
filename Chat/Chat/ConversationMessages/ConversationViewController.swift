//
//  ConversationViewController.swift
//  Chat
//
//  Created by Сергей on 05.10.2021.
//

import UIKit

class ConversationViewController: UIViewController {

	var user: User
	weak var delegate: ConversationsListViewControllerDelegate?
	var tableView: UITableView!
	var messageInputField: UITextView!
	var textinputView: UIView!
	
	private let inputID = "input"
	private let outputID = "output"
	private let maxHeightMessageInput = 120.0
	private let minHeightMessageInput = 32.0
	private var isKeyboerdHidden = true
	
	private var tapGesture: UITapGestureRecognizer!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = (traitCollection.userInterfaceStyle == .dark) ? .darkGray.withAlphaComponent(0.4) : UIColor(red: 239/255, green: 239/255, blue: 245/255, alpha: 1)
		
		self.navigationItem.title = user.fullName
		self.navigationController?.navigationBar.tintColor = (traitCollection.userInterfaceStyle == .light) ? .black : .white
//		self.navigationController?.navigationBar.backgroundColor = (traitCollection.userInterfaceStyle == .dark) ? .darkGray.withAlphaComponent(0.4) : UIColor(red: 239/255, green: 239/255, blue: 245/255, alpha: 1)
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil);
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil);
	
		tapGesture =  UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:)))
		self.view.addGestureRecognizer(tapGesture)
		
		textinputView = UIView()
		textinputView.backgroundColor = self.view.backgroundColor
		textinputView.translatesAutoresizingMaskIntoConstraints = false
		
		messageInputField = UITextView()
		messageInputField.layer.cornerRadius = 8
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
		let image = UIImage(named: "Send")
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
		textinputView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
		textinputView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
		textinputView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10).isActive = true
		

		tableView = UITableView(frame: CGRect.zero, style: .plain)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(MessageCell.self, forCellReuseIdentifier: inputID)
		tableView.register(MessageCell.self, forCellReuseIdentifier: outputID)
		tableView.separatorStyle = .none
		tableView.translatesAutoresizingMaskIntoConstraints = false
		
		self.view.addSubview(tableView)
		
		tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
		tableView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
		tableView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
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
		messageInputField.resignFirstResponder()
		if messageInputField.text.isEmpty {
			return
		}
		let newMessage = Message(body: messageInputField.text, date: Date(), unread: false, ownerID: 0)
		if user.messages == nil {
			self.user.messages = [newMessage]
		} else {
			self.user.messages!.append(newMessage)
		}
		messageInputField.text = ""

		self.tableView.reloadData()
		DispatchQueue.main.async {
			let cellNumber = self.user.messages!.count - 1
			let indexPath = IndexPath(row: cellNumber, section: 0)
			self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
		}
		//TODO: - Send request to server!
	}
	
	@objc func tapGestureAction(_ sender: UITapGestureRecognizer) {
		let location = sender.location(in: self.view)
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
			let height = (info["UIKeyboardFrameEndUserInfoKey"] as! CGRect).height
			let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - height)
			self.view.frame = frame
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
		isKeyboerdHidden = true
		guard let info = sender.userInfo else { return }
		let height = (info["UIKeyboardFrameEndUserInfoKey"] as! CGRect).height
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
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	//MARK: - Private functions
	private func resizeTextViewToFitText() {
		let size = CGSize(width: messageInputField.frame.width, height: .infinity)
		let expectedSize = messageInputField.sizeThatFits(size)
		for constraint in messageInputField.constraints {
			if constraint.firstAttribute == .height {
				constraint.constant = max(min(expectedSize.height, maxHeightMessageInput), minHeightMessageInput)
			}
		}
		if expectedSize.height > maxHeightMessageInput {
			messageInputField.heightAnchor.constraint(lessThanOrEqualToConstant: maxHeightMessageInput).isActive = true
			self.messageInputField.isScrollEnabled = true

		} else {
			self.messageInputField.isScrollEnabled = false
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
	
		let id = (user.messages?[indexPath.row].ownerID != 0) ? inputID : outputID
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
