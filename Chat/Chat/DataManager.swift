//
//  DataManager.swift
//  Chat
//
//  Created by Сергей on 02.11.2021.
//

import UIKit
import CoreData
import Firebase

final class DataManager {
	
	private enum Constants {
		static let channelKeyName = "name"
		static let channelKeyLastMessage = "lastMessage"
		static let channelKeyLastActivity = "lastActivity"
		static let messageKeyContent = "content"
		static let messageKeyCreated = "created"
		static let messageKeySenderId = "senderId"
		static let messageKeySenderName = "senderName"
	}
	
	static var shared: DataManager = {
		let instance = DataManager()
		return instance
	}()
	
	private init() {}
	
	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "Chat")
		container.loadPersistentStores { _, error in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		}
		container.viewContext.automaticallyMergesChangesFromParent = true
		return container
	}()
	
	func saveChannel(_ channel: DocumentChange) {
		persistentContainer.performBackgroundTask({ context in
			context.mergePolicy = NSMergePolicy.overwrite
			let newChannel = DBChannel(context: context)
			let data = channel.document.data()
			newChannel.identifier = channel.document.documentID
			newChannel.name = (data[Constants.channelKeyName] as? String) ?? ""
			newChannel.lastMessage = data[Constants.channelKeyLastMessage] as? String
			newChannel.lastActivity = (data[Constants.channelKeyLastActivity] as? Timestamp)?.dateValue()
			do {
				try context.save()
			} catch {
				let error = error as NSError
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
	}
	
	func removeChannel(_ channel: DocumentChange) {
		persistentContainer.performBackgroundTask({ context in
			let request: NSFetchRequest<DBChannel> = DBChannel.fetchRequest()
			let predicate = NSPredicate(format: "identifier like %@", channel.document.documentID)
			request.predicate = predicate
			do {
				if let channel = try context.fetch(request).first {
					context.delete(channel)
					try context.save()
				}
			} catch {
				let error = error as NSError
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
	}
	
	func loadChannels(_ predicate: NSPredicate? = nil) -> [DBChannel] {
		var channels: [DBChannel] = []
		let context = persistentContainer.viewContext
		let request: NSFetchRequest<DBChannel> = DBChannel.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "lastActivity", ascending: true)
		request.sortDescriptors = [sortDescriptor]
		if predicate != nil {
			request.predicate = predicate
		}
		do {
			channels = try context.fetch(request)
		} catch {
			let error = error as NSError
			fatalError("Unresolved error \(error), \(error.userInfo)")
		}
		return channels
	}
	
	func saveMessage(_ message: DocumentChange, forChannelId id: String) {
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
			let data = message.document.data()
			if !self.isMessageExist(messageData: data) {
				let newMessage = DBMessage(context: context)
				newMessage.content = (data[Constants.messageKeyContent] as? String) ?? ""
				newMessage.created = (data[Constants.messageKeyCreated] as? Timestamp)?.dateValue() ?? Date(timeIntervalSince1970: 0)
				newMessage.senderId = (data[Constants.messageKeySenderId] as? String) ?? ""
				newMessage.senderName = (data[Constants.messageKeySenderName] as? String) ?? ""
				channel.addToMessages(newMessage)
			}
			do {
				if context.hasChanges {
					try context.save()
				}
			} catch {
				let error = error as NSError
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
	}
	
	func isMessageExist(messageData: [String: Any]) -> Bool {
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
	
	func logChannelsContent(needPrintMessages isNeed: Bool = false) {
	#if DEBUG
		if CommandLine.arguments.contains("DEBUG_LOG_CHANNELS_CONTENT") {
			print("----------------------------------------------------------")
			print("*************** Core Data Channels content ***************")
			print("----------------------------------------------------------")
			let channels = loadChannels()
			for channel in channels {
				print("Name\t\t: " + (channel.name ?? "--empty--"))
				print("Identifier\t: " + (channel.identifier ?? "--empty--"))
				if #available(iOS 15.0, *) {
					print("Date\t\t: " + (channel.lastActivity?.formatted(date: .numeric, time: .shortened) ?? "--empty--"))
				}
				print("Last message: \(channel.lastMessage ?? "--empty--")")
				print("--------------------------------------------")
				if isNeed {
					if let id = channel.identifier {
						logMessagesContent(forChannelId: id)
					}
				}
			}
			print("Channels count: \(channels.count)")
			print("--------------------------------------------")
		}
	#endif
	}
	
	func logMessagesContent(forChannelId id: String) {
	#if DEBUG
		if CommandLine.arguments.contains("DEBUG_LOG_MESSAGES_CONTENT") {
			let messages = loadMessages(forChannelId: id)
			if messages.isEmpty {
				print("* There are no messages in the database for the current channel *")
				print("* Perhaps the channel is empty, or no data has been downloaded from Firebase *")
				print("--------------------------------------------")
				return
			}
			print("\t||----------------------------------------------------------")
			print("\t||*************** Core Data Messages content ***************")
			print("\t||----------------------------------------------------------")
			for message in messages {
				print("\t||\tSender Id\t: " + (message.senderId ?? "--empty--"))
				print("\t||\tSender name\t: " + (message.senderName ?? "--empty--"))
				if #available(iOS 15.0, *) {
					print("\t||\tCreated\t\t: " + (message.created?.formatted(date: .numeric, time: .shortened) ?? "--empty--"))
				}
				print("\t||\tMessage\t\t: \(message.content ?? "--empty--")")
				print("\t||--------------------------------------------")
			}
			print("\t||\tMessages count: \(messages.count)")
			print("\t||--------------------------------------------")
		}
	#endif
	}
}

extension DataManager: NSCopying {
	func copy(with zone: NSZone? = nil) -> Any {
		return self
	}
}
