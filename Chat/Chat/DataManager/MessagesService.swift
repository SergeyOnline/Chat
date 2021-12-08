//
//  MessageService.swift
//  Chat
//
//  Created by Сергей on 18.11.2021.
//

import Foundation
import CoreData
import Firebase

protocol IMessagesService {
	init(persistentContainer: NSPersistentContainer)
	func saveMessages(_ messages: [DocumentChange], forChannelId id: String, completion: @escaping () -> Void)
	func loadMessages(forChannelId id: String) -> [DBMessage]
	func messagesCount(forChannel id: String) -> Int
}

final class MessagesService: IMessagesService {
	
	private enum Constants {
		static let messageKeyContent = "content"
		static let messageKeyCreated = "created"
		static let messageKeySenderId = "senderId"
		static let messageKeySenderName = "senderName"
	}
	
	private let persistentContainer: NSPersistentContainer
	
	required init(persistentContainer: NSPersistentContainer) {
		self.persistentContainer = persistentContainer
	}
	
	func saveMessages(_ messages: [DocumentChange], forChannelId id: String, completion: @escaping () -> Void) {
		persistentContainer.performBackgroundTask({ context in
			context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
			var channels: [DBChannel] = []
			let predicate = NSPredicate(format: "identifier == %@", id)
			let request: NSFetchRequest<DBChannel> = DBChannel.fetchRequest()
			request.predicate = predicate
			do {
				channels = try context.fetch(request)
			} catch {
				let error = error as NSError
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
			guard let channel = channels.first else { return }
			messages.forEach { message in
				let data = message.document.data()
				if !self.isMessageExist(messageData: data) {
					let newMessage = DBMessage(context: context)
					newMessage.content = (data[Constants.messageKeyContent] as? String) ?? ""
					newMessage.created = (data[Constants.messageKeyCreated] as? Timestamp)?.dateValue() ?? Date(timeIntervalSince1970: 0)
					newMessage.senderId = (data[Constants.messageKeySenderId] as? String) ?? ""
					newMessage.senderName = (data[Constants.messageKeySenderName] as? String) ?? ""
					channel.addToMessages(newMessage)
				}
			}
			do {
				if context.hasChanges {
					try context.save()
					completion()
				}
			} catch {
				let error = error as NSError
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
	}
	
	func loadMessages(forChannelId id: String) -> [DBMessage] {
		var messages: [DBMessage] = []
		let context = persistentContainer.viewContext
		let request: NSFetchRequest<DBMessage> = DBMessage.fetchRequest()
		let predicate = NSPredicate(format: "channel != nil && channel.identifier like %@", id)
		let sortDescriptor = NSSortDescriptor(key: "created", ascending: true)
		request.sortDescriptors = [sortDescriptor]
		request.predicate = predicate
		do {
			messages = try context.fetch(request)
		} catch {
			let error = error as NSError
			fatalError("Unresolved error \(error), \(error.userInfo)")
		}
		return messages
	}
	
	func messagesCount(forChannel id: String) -> Int {
		var count = 0
		let context = persistentContainer.viewContext
		let request: NSFetchRequest<DBMessage> = DBMessage.fetchRequest()
		let predicate = NSPredicate(format: "channel != nil && channel.identifier like %@", id)
		request.predicate = predicate
		do {
			count = try context.count(for: request)
		} catch {
			let error = error as NSError
			fatalError("Unresolved error \(error), \(error.userInfo)")
		}
		return count
	}
	
	private func isMessageExist(messageData: [String: Any]) -> Bool {
		var messages: [DBMessage] = []
		let context = persistentContainer.viewContext
		if let content = messageData[Constants.messageKeyContent] as? String,
		   let created = (messageData[Constants.messageKeyCreated] as? Timestamp)?.dateValue(),
		   let senderName = messageData[Constants.messageKeySenderName] as? String,
		   let senderId = messageData[Constants.messageKeySenderId] as? String {
			let request: NSFetchRequest<DBMessage> = DBMessage.fetchRequest()
			let predicate = NSPredicate(format: "content == %@ AND created == %@ AND senderName == %@ AND senderId == %@",
										content,
										created as NSDate,
										senderName,
										senderId)
			request.predicate = predicate
			do {
				messages = try context.fetch(request)
				if !messages.isEmpty { return true }
			} catch {
				return false
			}
		}
		return false
	}
}
