//
//  MainViewController.swift
//  Chat
//
//  Created by Сергей on 24.09.2021.
//

import UIKit

protocol ConversationsListViewControllerDelegate: AnyObject {
	func changeMessagesForUserWhithID(_ id: Int, to: [Message]?)
}

final class ConversationsListViewController: UIViewController {
	
	private enum Constants {
		static let cellReuseIdentifier = "Cell"
		static let userImageViewCornerRadius = 20.0
		static let userImageViewWidth = 40.0
		static let userImageViewHeight = 40.0
		static let userImageViewLabelfontSize = 20.0
		static let tableViewRowHeight = 80.0
		static let settingsButtonImageName = "Gear"
	}
	
	private enum LocalizeKeys {
		static let navigationItemTitle = "navigationItemTitle"
		static let onlineHeaderTitle = "onlineHeaderTitle";
		static let offlineHeaderTitle = "offlineHeaderTitle";
	}
	
	var tableView: UITableView!
	
	private let users = TestData.users
	private var onlineUsers: [User] {
		get {
			var users = users.filter({ $0.online == true})
			users = sortUsers(users: users)
			return users
		}
	}
	private var offlineUsers: [User] {
		get {
			var users = users.filter({ $0.online == false})
			users = sortUsers(users: users)
			return users
		}
	}

	override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .systemGray
		navigationItem.title = NSLocalizedString(LocalizeKeys.navigationItemTitle, comment: "")
		
		let userImageView = UserImageView(labelTitle: Owner().initials, labelfontSize: Constants.userImageViewLabelfontSize)
		userImageView.layer.cornerRadius = Constants.userImageViewCornerRadius
	
		
		let profileBarButtonItem = UIBarButtonItem(customView: userImageView)
		profileBarButtonItem.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileBarButtonAction(_:))))
		userImageView.widthAnchor.constraint(equalToConstant: Constants.userImageViewWidth).isActive = true
		userImageView.heightAnchor.constraint(equalToConstant: Constants.userImageViewHeight).isActive = true
		
		let image = UIImage(named: Constants.settingsButtonImageName)
		let settingsBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(settingsBarButtonAction(_:)))
	
		navigationItem.rightBarButtonItem = profileBarButtonItem
		navigationItem.leftBarButtonItem = settingsBarButtonItem

		
		tableView = UITableView(frame: view.safeAreaLayoutGuide.layoutFrame, style: .grouped)

		tableView.register(ConversationsListCell.self, forCellReuseIdentifier: Constants.cellReuseIdentifier)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = Constants.tableViewRowHeight
//		tableView.rowHeight = UITableView.automaticDimension
//		tableView.estimatedRowHeight = 80

		view.addSubview(tableView)
    }

	//MARK: - Actions
	@objc func profileBarButtonAction(_ sender: UIBarButtonItem) {
		let profileViewController = ProfileViewController()
		present(profileViewController, animated: true, completion: nil)
	}
	
	@objc func settingsBarButtonAction(_ sender: UIBarButtonItem) {
		//TODO: - settings
		print("TO DO")
	}
	
	//MARK: - Private functions
	private func sortUsers(users: [User]) -> [User] {
		
		var hasUnreadMassageUsers = users.filter { $0.hasUnreadMessages == true }
		var otheUsers = users.filter { $0.hasUnreadMessages == false }
		hasUnreadMassageUsers = hasUnreadMassageUsers.sorted(by: { u1, u2 in
			return u1.messages!.last!.date > u2.messages!.last!.date
		})
		otheUsers = otheUsers.sorted(by: { u1, u2 in
			if u1.messages == nil && u2.messages == nil {
				return false
			} else if u1.messages == nil {
				return false
			} else if u2.messages == nil {
				return true
			} else {
				return u1.messages!.last!.date > u2.messages!.last!.date
			}
		})
		return hasUnreadMassageUsers + otheUsers
	}
}

extension ConversationsListViewController: UITableViewDelegate, UITableViewDataSource {

	// MARK: - Table view delegate, data source
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 1 {
			return offlineUsers.count
		}
		return onlineUsers.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier, for: indexPath) as! ConversationsListCell

		var currentUsers: [User] = []
		if indexPath.section == 0 {
			currentUsers = onlineUsers
		} else {
			currentUsers = offlineUsers
		}
		
		cell.name = currentUsers[indexPath.row].fullName
		if let message = currentUsers[indexPath.row].messages?.last {
			cell.message = message.body
			cell.date = message.date
		} else {
			cell.message = nil
			cell.date = nil
		}
		cell.online = currentUsers[indexPath.row].online
		cell.hasUnreadMessages = currentUsers[indexPath.row].hasUnreadMessages
		return cell
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0: return NSLocalizedString(LocalizeKeys.onlineHeaderTitle, comment: "")
		case 1: return NSLocalizedString(LocalizeKeys.offlineHeaderTitle, comment: "")
		default: return ""
		}
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		var conversationVC: ConversationViewController
		if indexPath.section == 0 {
			conversationVC = ConversationViewController(user: onlineUsers[indexPath.row])
		} else {
			conversationVC = ConversationViewController(user: offlineUsers[indexPath.row])
		}
		conversationVC.delegate = self
		self.navigationController?.pushViewController(conversationVC, animated: true)
	}
}

extension ConversationsListViewController: ConversationsListViewControllerDelegate {
	func changeMessagesForUserWhithID(_ id: Int, to messages: [Message]?) {
		for user in users {
			if user.id == id {
				user.messages = messages
				break
			}
		}
		self.tableView.reloadData()
	}
}