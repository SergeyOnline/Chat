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
		
		onlineUsers = users.filter({ $0.online == true}).sorted(by: { u1, u2 in
			u1.message.keys.sorted { $0 > $1 }[0] > u2.message.keys.sorted { $0 > $1 }[0]
		})
		
		offlineUsers = users.filter({ $0.online == false}).sorted(by: { u1, u2 in
			u1.message.keys.sorted { $0 > $1 }[0] > u2.message.keys.sorted { $0 > $1 }[0]
		})
		
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

		if indexPath.section == 0 {
			cell.name = onlineUsers[indexPath.row].fullName
			let key = onlineUsers[indexPath.row].message.keys.sorted(by: { $0 > $1 })[0]
			cell.message = onlineUsers[indexPath.row].message[key]
			cell.online = onlineUsers[indexPath.row].online
			cell.date = key
		} else {
			cell.name = offlineUsers[indexPath.row].fullName
			let key = offlineUsers[indexPath.row].message.keys.sorted(by: { $0 > $1 })[0]
			cell.message = offlineUsers[indexPath.row].message[key]
			cell.online = offlineUsers[indexPath.row].online
			cell.date = key
		}
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
