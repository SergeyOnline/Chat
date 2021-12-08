//
//  ConversationViewController+TableViewDataSource.swift
//  Chat
//
//  Created by Сергей on 18.11.2021.
//

import UIKit

extension ConversationViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return presenter?.getNumerOfSections() ?? 0
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return presenter?.getNumberOfRowsInSection(section) ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let id = presenter?.getCellIdForRowAt(indexPath: indexPath) ?? "Constants.outputID"
		guard let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as? MessageCell else {
			return UITableViewCell()
		}
		presenter?.configureCell(cell, atIndexPath: indexPath)
		return cell
	}
	
}
