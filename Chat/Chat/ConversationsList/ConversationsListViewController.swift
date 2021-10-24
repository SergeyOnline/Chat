//
//  MainViewController.swift
//  Chat
//
//  Created by Сергей on 24.09.2021.
//

import UIKit
import Firebase

final class ConversationsListViewController: UIViewController {
	
	private enum Constants {
		static let cellReuseIdentifier = "ConversationsListCell"
		static let userImageViewCornerRadius = 20.0
		static let userImageViewWidth = 40.0
		static let userImageViewHeight = 40.0
		static let userImageViewLabelfontSize = 20.0
		static let tableViewRowHeight = 80.0
		static let channelsDBCollection = "channels"
	}
	
	private enum LocalizeKeys {
		static let headerTitle = "headerTitle"
	}
	
	private lazy var db = Firestore.firestore()
	private lazy var referenceChannel = db.collection(Constants.channelsDBCollection)
	private lazy var channels: [Channel] = [] {
		didSet {
			tableView.reloadData()
		}
	}
	
	// MARK: - UI
	var tableView: UITableView = {
		let table = UITableView(frame: CGRect.zero, style: .grouped)
		return table
	}()
	
	var userImageView: UserImageView = {
		let imageView = UserImageView(labelTitle: Owner().initials, labelfontSize: Constants.userImageViewLabelfontSize)
		return imageView
	}()
	
	// MARK: - Model
	
	private let userProfileHandler: UserProfileInfoHandlerProtocol = {
		return GCDUserProfileInfoHandler()
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		view.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		navigationController?.navigationBar.barTintColor = NavigationBarAppearance.backgroundColor.uiColor()
		navigationController?.navigationBar.tintColor = NavigationBarAppearance.elementsColor.uiColor()
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key(rawValue:
																							NSAttributedString.Key.foregroundColor.rawValue):
																	NavigationBarAppearance.elementsColor.uiColor()]
		tableView.backgroundColor = TableViewAppearance.backgroundColor.uiColor()
		tableView.reloadData()
	}
	
	// MARK: - Actions
	@objc func profileBarButtonAction(_ sender: UIBarButtonItem) {
		let profileViewController = ProfileViewController()
		profileViewController.completion = {
			
			self.userProfileHandler.loadOwnerInfo { result in
				switch result {
				case .success(let owner):
					self.userImageView.setInitials(initials: owner.initials)
				case .failure:
					break
				}
			}
			
			self.userProfileHandler.loadOwnerImage { result in
				switch result {
				case .success(let image):
					self.userImageView.image = image
				case .failure:
					self.userImageView.image = nil
				}
			}
			
			// TODO: - User defaults
			//			if let imageData = UserDefaults.standard.data(forKey: UserDefaultsKeys.userImage) {
			//				self.userImageView.image = UIImage(data: imageData)
			//			} else {
			//				self.userImageView.image = nil
			//			}
		}
		present(profileViewController, animated: true, completion: nil)
	}
	
	// MARK: - Private functions
	
	private func setup() {
		getChannels()
		userImageView.layer.cornerRadius = Constants.userImageViewCornerRadius
		userProfileHandler.loadOwnerImage { result in
			switch result {
			case .success(let image):
				self.userImageView.image = image
			case .failure:
				self.userImageView.image = nil
			}
		}
		
		userProfileHandler.loadOwnerInfo { [weak self] in
			switch $0 {
			case .success(let owner):
				self?.userImageView.setInitials(initials: owner.initials)
			case .failure:
				self?.userImageView.setInitials(initials: Owner().initials)
			}
		}
		
		// TODO: - User defaults
		//		if let imageData = UserDefaults.standard.data(forKey: UserDefaultsKeys.userImage) {
		//			userImageView.image = UIImage(data: imageData)
		//		}
		
		userImageView.widthAnchor.constraint(equalToConstant: Constants.userImageViewWidth).isActive = true
		userImageView.heightAnchor.constraint(equalToConstant: Constants.userImageViewHeight).isActive = true
		
		setupTableView()
		view.addSubview(tableView)
		setupTableViewConstraints()
	}
	
	func getChannels() {
		var channels: [Channel] = []
		referenceChannel.getDocuments { querySnapshot, error in
			if let error = error {
				print("Error getting documents: \(error)")
				return
			}
			if let documents = querySnapshot?.documents {
				for document in documents {
					let data = document.data()
					let id: String = document.documentID
					let name: String = (data["name"] as? String) ?? ""
					let lastMessage: String? = data["lastMessage"] as? String
					let lastActivity: Date? = data["lastActivity"] as? Date
					let channel = Channel(identifier: id, name: name, lastMessage: lastMessage, lastActivity: lastActivity)
					channels.append(channel)
				}
			}
			DispatchQueue.main.async {
				self.channels = channels
			}
		}
		
		referenceChannel.addSnapshotListener { [weak self] querySnapshot, error in
			var channels: [Channel] = []
			if let error = error {
				print("Error getting documents: \(error)")
				return
			}
			if let documents = querySnapshot?.documents {
				for document in documents {
					let data = document.data()
					let id: String = document.documentID
					let name: String = (data["name"] as? String) ?? ""
					let lastMessage: String? = data["lastMessage"] as? String
					let lastActivity: Date? = data["lastActivity"] as? Date
					let channel = Channel(identifier: id, name: name, lastMessage: lastMessage, lastActivity: lastActivity)
					channels.append(channel)
				}
			}
			DispatchQueue.main.async {
				self?.channels = channels
				self?.tableView.reloadData()
			}
		}
		
	}
	
	// MARK: - Private functions
	private func logThemeChanging() {
		print(Theme.theme)
	}
	
	// MARK: - setup Table View and Constraints
	
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
		tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
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
}

extension ConversationsListViewController: UITableViewDelegate, UITableViewDataSource {
	
	// MARK: - Table view delegate, data source
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return channels.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier, for: indexPath) as? ConversationsListCell else {
			return UITableViewCell()
		}
		
		cell.name = channels[indexPath.row].name
		cell.message = channels[indexPath.row].lastMessage
		cell.date = channels[indexPath.row].lastActivity
		cell.online = true
//		cell.hasUnreadMessages = false
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return NSLocalizedString(LocalizeKeys.headerTitle, comment: "")
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		var conversationVC: ConversationViewController
		conversationVC = ConversationViewController(channel: channels[indexPath.row])
		self.navigationController?.pushViewController(conversationVC, animated: true)
	}
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		guard let header = view as? UITableViewHeaderFooterView else { return }
		header.textLabel?.textColor = TableViewAppearance.headerTitleColor.uiColor()
	}
}
