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
		static let tableViewRowHeight = 80.0
		static let channelsDBCollection = "channels"
		static let channelKeyName = "name"
		static let channelKeyLastMessage = "lastMessage"
		static let channelKeyLastActivity = "lastActivity"
	}
	
	private enum LocalizeKeys {
		static let headerTitle = "headerTitle"
	}
	
	private lazy var db = Firestore.firestore()
	private lazy var referenceChannel = db.collection(Constants.channelsDBCollection)
	private let dataManager = DataManager.shared
	
	// MARK: - UI
	var tableView: UITableView = {
		let table = UITableView(frame: CGRect.zero, style: .grouped)
		return table
	}()
	
	// MARK: - Model
	private lazy var channels: [Channel] = [] {
		didSet {
			tableView.reloadData()
		}
	}

	private let userProfileHandler: UserProfileInfoHandlerProtocol = {
		return GCDUserProfileInfoHandler()
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
		// MARK - Change the initializer, if you need to display the entire contents of the database
//		dataManager.logChannelsContent(needPrintMessages: true)
		dataManager.logChannelsContent()
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
	
	// MARK: - Private functions
	
	private func setup() {
		getChannels()
		Timer.scheduledTimer(withTimeInterval: 540, repeats: true) { _ in
				self.tableView.reloadData()
		}
		setupTableView()
		view.addSubview(tableView)
		setupTableViewConstraints()
	}
	
	func getChannels() {
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
					let name: String = (data[Constants.channelKeyName] as? String) ?? ""
					let lastMessage: String? = data[Constants.channelKeyLastMessage] as? String
					let lastActivity: Date? = (data[Constants.channelKeyLastActivity] as? Timestamp)?.dateValue()
					let channel = Channel(identifier: id, name: name, lastMessage: lastMessage, lastActivity: lastActivity)
					channels.append(channel)
				}
			}
			DispatchQueue.main.async {
				self?.channels = channels.sorted(by: { ch1, ch2 in
					if ch1.lastActivity == nil && ch2.lastActivity == nil {
						return false
					} else if ch1.lastActivity == nil {
						return false
					} else if ch2.lastActivity == nil {
						return true
					} else {
						guard let lastCh1Date = ch1.lastActivity else { return false }
						guard let lastCh2Date = ch2.lastActivity else { return false }
						return lastCh1Date > lastCh2Date
					}
				})
				guard let channels = self?.channels else { return }
				self?.dataManager.saveChannels(channels)
			}
		}
	}
	
	// MARK: - setup Table View and Constraints
	private func setupTableView() {
		tableView.register(ConversationsListCell.self, forCellReuseIdentifier: Constants.cellReuseIdentifier)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = Constants.tableViewRowHeight
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.estimatedRowHeight = 80
	}
	
	private func setupTableViewConstraints() {
		tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
		tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
		tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
	}
	
	// TODO: - The function is not used in the current version, but left for further modifications of the project
//	private func sortUsers(users: [User]) -> [User] {
//
//		var hasUnreadMassageUsers = users.filter { $0.hasUnreadMessages == true }
//		var otheUsers = users.filter { $0.hasUnreadMessages == false }
//		hasUnreadMassageUsers = hasUnreadMassageUsers.sorted(by: { u1, u2 in
//
//			guard let lastU1Date = u1.messages?.last?.date else { return false }
//			guard let lastU2Date = u2.messages?.last?.date else { return false }
//
//			return lastU1Date > lastU2Date
//		})
//		otheUsers = otheUsers.sorted(by: { u1, u2 in
//			if u1.messages == nil && u2.messages == nil {
//				return false
//			} else if u1.messages == nil {
//				return false
//			} else if u2.messages == nil {
//				return true
//			} else {
//				guard let lastU1Date = u1.messages?.last?.date else { return false }
//				guard let lastU2Date = u2.messages?.last?.date else { return false }
//				return lastU1Date > lastU2Date
//			}
//		})
//		return hasUnreadMassageUsers + otheUsers
//	}
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
		if let timeInterval = channels[indexPath.row].lastActivity?.timeIntervalSince(Date()) {
			cell.online = -timeInterval <= 600
		} else {
			cell.online = false
		}
		// TODO: - use unread message
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
