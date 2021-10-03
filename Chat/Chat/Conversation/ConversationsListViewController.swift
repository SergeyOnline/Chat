//
//  MainViewController.swift
//  Chat
//
//  Created by Сергей on 24.09.2021.
//

import UIKit

class ConversationsListViewController: UIViewController {
	
	private let reuseIdentifier = "Cell"
	
	var tableView: UITableView!
	
	private let users = TestData.users
	private var onlineUsers: [User]!
	private var offlineUsers: [User]!

	override func viewDidLoad() {
        super.viewDidLoad()
		
		print("Users: \(users.count)")
		onlineUsers = users.filter({ $0.online == true})
		onlineUsers = sortUsers(users: onlineUsers)
		offlineUsers = users.filter({ $0.online == false})
		offlineUsers = sortUsers(users: offlineUsers)
		print("Users online: \(onlineUsers.count)")
		print("Users offline: \(offlineUsers.count)")
	
		
		self.view.backgroundColor = .systemGray
		self.navigationItem.title = NSLocalizedString("navigationItemTitle", comment: "")
		
		let userImageView = UserImageView(labelTitle: Owner().initials, labelfontSize: 20)
		userImageView.layer.cornerRadius = 20
	
		
		let profileBarButtonItem = UIBarButtonItem(customView: userImageView)
		profileBarButtonItem.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileBarButtonAction(_:))))
		userImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
		userImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
		
		let image = UIImage(named: "Gear")
		let settingsBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(settingsBarButtonAction(_sender:)))
	
		self.navigationItem.rightBarButtonItem = profileBarButtonItem
		self.navigationItem.leftBarButtonItem = settingsBarButtonItem

		
		tableView = UITableView(frame: self.view.safeAreaLayoutGuide.layoutFrame, style: .grouped)

		tableView.register(ConversationCell.self, forCellReuseIdentifier: reuseIdentifier)
		tableView.delegate = self
		tableView.dataSource = self
//		tableView.rowHeight = 80
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 80

		self.view.addSubview(tableView)
    }

	//MARK: - Actions
	@objc func profileBarButtonAction(_ sender: UIBarButtonItem) {
		let profileViewController = ProfileViewController()
		self.present(profileViewController, animated: true, completion: nil)
	}
	
	@objc func settingsBarButtonAction(_sender: UIBarButtonItem) {
		//TODO: - settings
		print("TO DO")
	}
	
	//MARK: - Private functions
	private func sortUsers(users: [User]) -> [User] {
		var hasUnreadMassageUsers = users.filter { $0.hasUnreadMessages == true && $0.message != nil }
		var otheUsers = users.filter { $0.hasUnreadMessages == false || ($0.hasUnreadMessages && $0.message == nil)}
		hasUnreadMassageUsers = hasUnreadMassageUsers.sorted(by: { u1, u2 in
			return u1.message!.keys.sorted { $0 > $1 }[0] > u2.message!.keys.sorted { $0 > $1 }[0]
		})
		otheUsers = otheUsers.sorted(by: { u1, u2 in
			if u1.message == nil && u2.message == nil {
				return false
			} else if u1.message == nil {
				return false
			} else if u2.message == nil {
				return true
			} else {
				return u1.message!.keys.sorted { $0 > $1 }[0] > u2.message!.keys.sorted { $0 > $1 }[0]
			}
		})
		return hasUnreadMassageUsers + otheUsers
	}
}

extension ConversationsListViewController: UITableViewDelegate, UITableViewDataSource {

	// MARK: - Table view data source
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
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ConversationCell

		var currentUsers: [User] = []
		if indexPath.section == 0 {
			currentUsers = onlineUsers
		} else {
			currentUsers = offlineUsers
		}
		
		cell.name = currentUsers[indexPath.row].fullName
		if let key = currentUsers[indexPath.row].message?.keys.sorted(by: { $0 > $1 })[0] {
			cell.message = currentUsers[indexPath.row].message![key]
			cell.date = key
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
		case 0: return "Online"
		case 1: return "History"
		default: return ""
		}
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}

}
