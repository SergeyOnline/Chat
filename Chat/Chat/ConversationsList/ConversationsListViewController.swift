//
//  MainViewController.swift
//  Chat
//
//  Created by Сергей on 24.09.2021.
//

import UIKit
import Firebase
import CoreData

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
	private var listener: ListenerRegistration?
	
	private lazy var fetchResultController: NSFetchedResultsController<DBChannel> = {
		let request: NSFetchRequest<DBChannel> = DBChannel.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "lastActivity", ascending: false)
		request.fetchBatchSize = 20
		request.sortDescriptors = [sortDescriptor]
		let controller = NSFetchedResultsController(fetchRequest: request,
													managedObjectContext: dataManager.persistentContainer.viewContext,
													sectionNameKeyPath: nil,
													cacheName: "channels")
		controller.delegate = self
		do {
			try controller.performFetch()
		} catch {
			fatalError("Failed to fetch entities: \(error)")
		}
		return controller
	}()
	
	// MARK: - UI
	var tableView = UITableView(frame: CGRect.zero, style: .grouped)

	private let userProfileHandler: UserProfileInfoHandlerProtocol = {
		return GCDUserProfileInfoHandler()
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
		// MARK: - Change the initializer, if you need to display the entire contents of the database
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
//		fetchResultController.delegate = self
	}
	
	// MARK: - Private functions
	
	private func setup() {
		getChannels()
		// Updating the table is only needed to show online status
		// Comment out to match the assignment do not use the tableView.reloadData() method
		Timer.scheduledTimer(withTimeInterval: 540, repeats: true) { _ in
				self.tableView.reloadData()
		}
		setupTableView()
		view.addSubview(tableView)
		setupTableViewConstraints()
	}
	
	func getChannels() {
		listener = referenceChannel.addSnapshotListener { [weak self] querySnapshot, error in
			if let error = error {
				print("Error getting documents: \(error)")
				return
			}
			guard let snapshot = querySnapshot else {
				print("Error fetching snapshots: \(error!)")
				return
			}
			var channels: [DocumentChange] = []
			snapshot.documentChanges.forEach { channel in
				if channel.type == .added {
					channels.append(channel)
				}
				if channel.type == .modified {
					channels.append(channel)
				}
				if channel.type == .removed {
					self?.dataManager.removeChannel(channel)
				}
			}
			self?.dataManager.saveChannels(channels)
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
	
	deinit {
		listener?.remove()
	}
}

extension ConversationsListViewController: UITableViewDelegate, UITableViewDataSource {
	
	// MARK: - Table view delegate, data source
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
		guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier, for: indexPath) as? ConversationsListCell else {
			return UITableViewCell()
		}
		configureCell(cell, atIndexPath: indexPath)
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
		let channel = fetchResultController.object(at: indexPath)
//		fetchResultController.delegate = nil
		conversationVC = ConversationViewController(channel: channel)
		self.navigationController?.pushViewController(conversationVC, animated: true)
	}
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		guard let header = view as? UITableViewHeaderFooterView else { return }
		header.textLabel?.textColor = TableViewAppearance.headerTitleColor.uiColor()
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let channel = fetchResultController.object(at: indexPath)
			if let id = channel.identifier {
				referenceChannel.document(id).delete { err in
					if let err = err {
						print("Error removing document: \(err)")
					} else {
						print("Document successfully removed!")
					}
				}
			}
		}
	}
	
	private func configureCell(_ cell: ConversationsListCell, atIndexPath indexPath: IndexPath) {
		let channel = fetchResultController.object(at: indexPath)
		cell.name = channel.name
		cell.message = channel.lastMessage
		cell.date = channel.lastActivity
		if let timeInterval = channel.lastActivity?.timeIntervalSince(Date()) {
			cell.online = -timeInterval <= 600
		} else {
			cell.online = false
		}
	}
}

extension ConversationsListViewController: NSFetchedResultsControllerDelegate {
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.beginUpdates()
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableView.endUpdates()
	}
	
	func controller(
		_ controller: NSFetchedResultsController<NSFetchRequestResult>,
		didChange anObject: Any,
		at indexPath: IndexPath?, for type: NSFetchedResultsChangeType,
		newIndexPath: IndexPath?
	) {
		switch type {
		case .insert:
			guard let newIndexPath = newIndexPath else { return	}
			tableView.insertRows(at: [newIndexPath], with: .fade)
		case .delete:
			guard let indexPath = indexPath else { return	}
			tableView.deleteRows(at: [indexPath], with: .fade)
		case .update:
			guard let indexPath = indexPath else { return }
//			guard let cell = tableView.cellForRow(at: indexPath) as? ConversationsListCell else { return }
//			configureCell(cell, atIndexPath: indexPath)
			tableView.reloadRows(at: [indexPath], with: .automatic)
		case .move:
			guard let indexPath = indexPath else { return }
			guard let newIndexPath = newIndexPath else { return	}
			tableView.deleteRows(at: [indexPath], with: .fade)
			tableView.insertRows(at: [newIndexPath], with: .fade)
		default: break
		}
	}
	
}
