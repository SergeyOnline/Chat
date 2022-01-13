//
//  ConversationsListViewController+TableViewDelegate.swift
//  Chat
//
//  Created by Сергей on 18.11.2021.
//

import UIKit

extension ConversationsListViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let channel = fetchResultController.object(at: indexPath)
//		var conversationVC: ConversationViewController
//		conversationVC = ConversationViewController(channel: channel)
		let conversationVC = ModuleAssembly.createConversationMessgesNodule(forChannel: channel)
		self.navigationController?.pushViewController(conversationVC, animated: true)
	}
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		guard let header = view as? UITableViewHeaderFooterView else { return }
		header.textLabel?.textColor = TableViewAppearance.headerTitleColor.uiColor()
	}
	
}
