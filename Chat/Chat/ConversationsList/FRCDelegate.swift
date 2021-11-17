//
//  FRCDelegate.swift
//  Chat
//
//  Created by Сергей on 17.11.2021.
//

import UIKit
import CoreData

class FRCDelegate: NSObject, NSFetchedResultsControllerDelegate {
	
	let conversationsListViewController: ConversationsListViewController
		
	init(conversationsListViewController: ConversationsListViewController) {
		self.conversationsListViewController = conversationsListViewController
	}
	
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		conversationsListViewController.tableView.beginUpdates()
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		conversationsListViewController.tableView.endUpdates()
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
			conversationsListViewController.tableView.insertRows(at: [newIndexPath], with: .fade)
		case .delete:
			guard let indexPath = indexPath else { return	}
			conversationsListViewController.tableView.deleteRows(at: [indexPath], with: .fade)
		case .update:
			guard let indexPath = indexPath else { return }
			conversationsListViewController.tableView.reloadRows(at: [indexPath], with: .automatic)
		case .move:
			guard let indexPath = indexPath else { return }
			guard let newIndexPath = newIndexPath else { return	}
			conversationsListViewController.tableView.deleteRows(at: [indexPath], with: .fade)
			conversationsListViewController.tableView.insertRows(at: [newIndexPath], with: .fade)
		default: break
		}
	}
	
}
