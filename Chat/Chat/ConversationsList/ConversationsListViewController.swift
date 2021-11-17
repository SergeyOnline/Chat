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
	private let dataManager = DataManager.shared
	private var listener: ListenerRegistration?
	
	lazy var referenceChannel = db.collection(Constants.channelsDBCollection)
	lazy var fetchedResultsController: NSFetchedResultsController<DBChannel> = {
		let request: NSFetchRequest<DBChannel> = DBChannel.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: Constants.channelKeyLastActivity, ascending: false)
		request.fetchBatchSize = 20
		request.sortDescriptors = [sortDescriptor]
		let controller = NSFetchedResultsController(fetchRequest: request,
													managedObjectContext: dataManager.persistentContainer.viewContext,
													sectionNameKeyPath: nil,
													cacheName: Constants.channelsDBCollection)
		controller.delegate = frcDelegate
		do {
			try controller.performFetch()
		} catch {
			fatalError("Failed to fetch entities: \(error)")
		}
		return controller
	}()
	
	private lazy var frcDelegate = FRCDelegate(conversationsListViewController: self)
	private lazy var tableViewDataSource = TableViewDataSource(conversationsListViewController: self)
	private lazy var tableViewDelegate = TableViewDelegate(conversationsListViewController: self)
	
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
	}
	
	// MARK: - Private functions
	
	private func setup() {
		setListener()
		// Updating the table is only needed to show online status
		// Comment out to match the assignment do not use the tableView.reloadData() method
		Timer.scheduledTimer(withTimeInterval: 540, repeats: true) { _ in
				self.tableView.reloadData()
		}
		setupTableView()
		view.addSubview(tableView)
		setupTableViewConstraints()
	}
	
	func setListener() {
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
		tableView.dataSource = tableViewDataSource
		tableView.delegate = tableViewDelegate
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
