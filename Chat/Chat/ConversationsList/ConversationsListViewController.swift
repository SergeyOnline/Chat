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
		static let cellReuseIdentifier = "ConversationsListCell"
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
	
	//MARK: - UI
	var tableView: UITableView = {
		let table = UITableView(frame: CGRect.zero, style: .grouped)
		return table
	}()
	
	var userImageView: UserImageView = {
		let imageView = UserImageView(labelTitle: Owner().initials, labelfontSize: Constants.userImageViewLabelfontSize)
		return imageView
	}()
	
	//MARK: - Model
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
		setup()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		view.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		navigationController?.navigationBar.barTintColor = NavigationBarAppearance.backgroundColor.uiColor()
		navigationController?.navigationBar.tintColor = NavigationBarAppearance.elementsColor.uiColor()
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): NavigationBarAppearance.elementsColor.uiColor()]
		tableView.backgroundColor = TableViewAppearance.backgroundColor.uiColor()
		
	}

	//MARK: - Actions
	@objc func profileBarButtonAction(_ sender: UIBarButtonItem) {
		let profileViewController = ProfileViewController()
		profileViewController.completion = {
			if let imageData = UserDefaults.standard.data(forKey: UserDefaultsKeys.userImage) {
				self.userImageView.image = UIImage(data: imageData)
			} else {
				self.userImageView.image = nil
			}
		}
		present(profileViewController, animated: true, completion: nil)
	}
	
	@objc func settingsBarButtonAction(_ sender: UIBarButtonItem) {
		let themesVC = ThemesViewController()
		themesVC.modalPresentationStyle = .fullScreen
		themesVC.completion = {
			self.tableView.reloadData()
			self.viewWillAppear(false)
			self.logThemeChanging()
		}
		present(themesVC, animated: true, completion: nil)
	}
	
	//MARK: -- Private functions
	
	private func setup() {
		navigationItem.title = NSLocalizedString(LocalizeKeys.navigationItemTitle, comment: "")
		navigationItem.backButtonTitle = ""
		
		userImageView.layer.cornerRadius = Constants.userImageViewCornerRadius
		if let imageData = UserDefaults.standard.data(forKey: UserDefaultsKeys.userImage) {
			userImageView.image = UIImage(data: imageData)
		}
		
		let profileBarButtonItem = UIBarButtonItem(customView: userImageView)
		profileBarButtonItem.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileBarButtonAction(_:))))
		userImageView.widthAnchor.constraint(equalToConstant: Constants.userImageViewWidth).isActive = true
		userImageView.heightAnchor.constraint(equalToConstant: Constants.userImageViewHeight).isActive = true
		
		let image = UIImage(named: Constants.settingsButtonImageName)
		let settingsBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(settingsBarButtonAction(_:)))
	
		navigationItem.rightBarButtonItem = profileBarButtonItem
		navigationItem.leftBarButtonItem = settingsBarButtonItem

		setupTableView()
		view.addSubview(tableView)
		setupTableViewConstraints()
	}
	
	//MARK: - setup Table View and Constraints
	
	private func setupTableView() {
		tableView.register(ConversationsListCell.self, forCellReuseIdentifier: Constants.cellReuseIdentifier)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = Constants.tableViewRowHeight
		tableView.translatesAutoresizingMaskIntoConstraints = false
//		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 80
	}
	
	private func setupTableViewConstraints() {
		tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
		tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
		tableView.bottomAnchor.constraint(equalTo:  view.bottomAnchor).isActive = true
	}
	
	private func sortUsers(users: [User]) -> [User] {
		
		var hasUnreadMassageUsers = users.filter { $0.hasUnreadMessages == true }
		var otheUsers = users.filter { $0.hasUnreadMessages == false }
		hasUnreadMassageUsers = hasUnreadMassageUsers.sorted(by: { u1, u2 in
			
			guard let lastU1Date = u1.messages?.last?.date else { return false }
			guard let lastU2Date = u2.messages?.last?.date else { return false }

			return lastU1Date > lastU2Date
		})
		otheUsers = otheUsers.sorted(by: { u1, u2 in
			if u1.messages == nil && u2.messages == nil {
				return false
			} else if u1.messages == nil {
				return false
			} else if u2.messages == nil {
				return true
			} else {
				guard let lastU1Date = u1.messages?.last?.date else { return false }
				guard let lastU2Date = u2.messages?.last?.date else { return false }
				return lastU1Date > lastU2Date
			}
		})
		return hasUnreadMassageUsers + otheUsers
	}
	
	private func logThemeChanging() {
		print(Theme.theme)
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
		guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier, for: indexPath) as? ConversationsListCell else {
			return UITableViewCell()
		}
		
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
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		guard let header = view as? UITableViewHeaderFooterView else { return }
		header.textLabel?.textColor = TableViewAppearance.headerTitleColor.uiColor()
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
