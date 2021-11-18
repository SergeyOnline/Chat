//
//  ConversationsListViewController+TableViewDataSource.swift
//  Chat
//
//  Created by Сергей on 18.11.2021.
//

import UIKit

extension ConversationsListViewController: UITableViewDataSource {
	
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
