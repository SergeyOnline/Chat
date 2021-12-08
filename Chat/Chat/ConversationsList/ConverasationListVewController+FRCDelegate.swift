//
//  ConverasationVewController+FRCDelegate.swift
//  Chat
//
//  Created by Сергей on 18.11.2021.
//

import UIKit
import CoreData

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
