//
//  ConversationViewController+TableViewDataSource.swift
//  Chat
//
//  Created by Сергей on 18.11.2021.
//

import UIKit

extension ConversationViewController: UITableViewDataSource {
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
		let message = fetchResultController.object(at: indexPath)
		let id = (message.senderId != ownerID) ? Constants.inputID : Constants.outputID
		guard let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as? MessageCell else {
			return UITableViewCell()
		}
		configureCell(cell, atIndexPath: indexPath)
		return cell
	}
	
	private func configureCell(_ cell: MessageCell, atIndexPath indexPath: IndexPath) {
		let index = indexPath.row
		guard let messages = fetchResultController.fetchedObjects else { return }
		tailsArray = [true]
		if messages.count >= 1 {
			for i in 1..<messages.count {
				if i == 0 {	continue }
				tailsArray.append(true)
				if messages[i].senderId == messages[i - 1].senderId {
					tailsArray[i - 1] = false
				}
			}
		}
		if index < tailsArray.count {
			cell.isTailNeed = tailsArray[index]
		}
		let message = fetchResultController.object(at: indexPath)
		let name = message.senderName ?? ""
		if index == 0 {
			cell.nameLabel.text = name.isEmpty ? "Unknown" : name
		} else {
			cell.nameLabel.text = (index < tailsArray.count && tailsArray[index - 1] == true) ? (name.isEmpty ? "Unknown" : name) : ""
		}
		cell.newDayLabel.text = calculateHeaderForMessagesOfOneDay(forCellIndex: indexPath)
		cell.messageText = message.content ?? ""
		cell.date = stringFromDate(message.created ?? nil, whithFormat: DateFormat.hourAndMinute)
	}
	
	private func stringFromDate(_ date: Date?, whithFormat format: String) -> String {
		guard let d = date else { return "" }
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: d)
	}
	
	private func calculateHeaderForMessagesOfOneDay(forCellIndex indexPath: IndexPath) -> String {
		let message = fetchResultController.object(at: indexPath)
		let prevMessage: DBMessage
		if indexPath.row != 0 {
			let prevIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
			prevMessage = fetchResultController.object(at: prevIndexPath)
		} else {
			prevMessage = message
		}
		var result = ""
		let calendar = Calendar(identifier: .gregorian)
		if indexPath.row == 0 {
			if let currentMessageDate = message.created {
				if calendar.startOfDay(for: currentMessageDate) == calendar.startOfDay(for: Date()) {
					result = NSLocalizedString(LocalizeKeys.headerDateTitle, comment: "")
				} else {
					result = stringFromDate(currentMessageDate, whithFormat: DateFormat.dayAndMonth)
				}
			}
		} else {
			if let currentMessageDate = message.created, let previosMessageDate = prevMessage.created {
				let beginningDayCurent = calendar.startOfDay(for: currentMessageDate)
				let beginningDayPrevios = calendar.startOfDay(for: previosMessageDate)
				if beginningDayCurent != beginningDayPrevios {
					if beginningDayCurent == calendar.startOfDay(for: Date()) {
						result = NSLocalizedString(LocalizeKeys.headerDateTitle, comment: "")
					} else {
						result = stringFromDate(currentMessageDate, whithFormat: DateFormat.dayAndMonth)
					}
				}
			}
		}
		return result
	}
}
