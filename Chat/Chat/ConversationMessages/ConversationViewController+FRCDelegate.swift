//
//  ConversationViewControllerExtensions.swift
//  Chat
//
//  Created by Сергей on 09.11.2021.
//

import UIKit
import CoreData

extension ConversationViewController: NSFetchedResultsControllerDelegate {
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
			tableView.insertRows(at: [newIndexPath], with: .none)
		case .delete:
			guard let indexPath = indexPath else { return	}
			tableView.deleteRows(at: [indexPath], with: .none)
		case .update:
			guard let indexPath = indexPath else { return }
			tableView.reloadRows(at: [indexPath], with: .none)
		case .move:
			guard let indexPath = indexPath else { return }
			guard let newIndexPath = newIndexPath else { return	}
			tableView.deleteRows(at: [indexPath], with: .none)
			tableView.insertRows(at: [newIndexPath], with: .none)
		default: break
		}
	}
}
