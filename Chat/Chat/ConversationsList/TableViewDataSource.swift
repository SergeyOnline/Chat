//
//  TableViewDataSource.swift
//  Chat
//
//  Created by Сергей on 17.11.2021.
//

import UIKit
import CoreData

class TableViewDataSource: NSObject, UITableViewDataSource {
	
	private enum Constants {
		static let cellReuseIdentifier = "ConversationsListCell"
	}
	
	private enum LocalizeKeys {
		static let headerTitle = "headerTitle"
	}
	
	let conversationsListViewController: ConversationsListViewController
		
	init(conversationsListViewController: ConversationsListViewController) {
		self.conversationsListViewController = conversationsListViewController
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return conversationsListViewController.fetchedResultsController.sections?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let sections = conversationsListViewController.fetchedResultsController.sections else {
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
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let channel = conversationsListViewController.fetchedResultsController.object(at: indexPath)
			if let id = channel.identifier {
				conversationsListViewController.referenceChannel.document(id).delete { err in
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
		let channel = conversationsListViewController.fetchedResultsController.object(at: indexPath)
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
