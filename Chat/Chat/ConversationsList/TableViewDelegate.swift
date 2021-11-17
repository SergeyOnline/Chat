//
//  TableViewDelegate.swift
//  Chat
//
//  Created by Сергей on 17.11.2021.
//

import UIKit
import CoreData

class TableViewDelegate: NSObject, UITableViewDelegate {
	
	let conversationsListViewController: ConversationsListViewController
		
	init(conversationsListViewController: ConversationsListViewController) {
		self.conversationsListViewController = conversationsListViewController
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		var conversationVC: ConversationViewController
		let channel = conversationsListViewController.fetchedResultsController.object(at: indexPath)
//		fetchResultController.delegate = nil
		conversationVC = ConversationViewController(channel: channel)
		conversationsListViewController.navigationController?.pushViewController(conversationVC, animated: true)
	}
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		guard let header = view as? UITableViewHeaderFooterView else { return }
		header.textLabel?.textColor = TableViewAppearance.headerTitleColor.uiColor()
	}
}
