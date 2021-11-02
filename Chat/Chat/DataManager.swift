//
//  DataManager.swift
//  Chat
//
//  Created by Сергей on 02.11.2021.
//

import UIKit
import CoreData

final class DataManager {
	
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
		return container
	}()
	
	func saveChannels(_ channels: [Channel]) {
		for channel in channels {
			persistentContainer.performBackgroundTask({ context in
				context.mergePolicy = NSMergePolicy.overwrite
				let newChannel = DBChannel(context: context)
				newChannel.name = channel.name
				newChannel.identifier = channel.identifier
				newChannel.lastActivity = channel.lastActivity
				newChannel.lastMessage = channel.lastMessage
				do {
					try context.save()
				} catch {
					let error = error as NSError
					fatalError("Unresolved error \(error), \(error.userInfo)")
				}
			})
		}
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
	
	func saveMessages(_ messages: [ChannelMessage], forChannelId id: String) {
		
		persistentContainer.performBackgroundTask({ context in
			context.mergePolicy = NSMergePolicy.overwrite
			var channels: [DBChannel] = []
			let predicate = NSPredicate(format: "identifier like %@", id)
			let request: NSFetchRequest<DBChannel> = DBChannel.fetchRequest()
			request.predicate = predicate
			do {
				channels = try context.fetch(request)
			} catch {
				let error = error as NSError
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
			
			guard let channel = channels.first else { return }
			
			for message in messages {
				context.mergePolicy = NSMergePolicy.overwrite
				let newMessage = DBMessage(context: context)
				newMessage.content = message.content
				newMessage.created = message.created
				newMessage.senderId = message.senderId
				newMessage.senderName = message.senderName
				newMessage.channel = channel
				do {
					try context.save()
				} catch {
					let error = error as NSError
					fatalError("Unresolved error \(error), \(error.userInfo)")
				}
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
				print("----------------------------------")
				if isNeed {
					if let id = channel.identifier {
						logMessagesContent(forChannelId: id)
						print("\n")
					}
				}
			}
			print("Channels count: \(channels.count)")
		}
		#endif
	}
	
	func logMessagesContent(forChannelId id: String) {
		#if DEBUG
		if CommandLine.arguments.contains("DEBUG_LOG_MESSAGES_CONTENT") {
			print("\t||----------------------------------------------------------")
			print("\t||*************** Core Data Messages content ***************")
			print("\t||----------------------------------------------------------")
			let messages = loadMessages(forChannelId: id)
			for message in messages {
				print("\t||\tSender Id\t: " + (message.senderId ?? "--empty--"))
				print("\t||\tSender name\t: " + (message.senderName ?? "--empty--"))
				if #available(iOS 15.0, *) {
					print("\t||\tCreated\t\t: " + (message.created?.formatted(date: .numeric, time: .shortened) ?? "--empty--"))
				}
				print("\t||\tMessage\t: \(message.content ?? "--empty--")")
				print("\t||----------------------------------")
			}
			print("\t||\tMessages count: \(messages.count)")
		}
		#endif
	}
}

extension DataManager: NSCopying {
	func copy(with zone: NSZone? = nil) -> Any {
		return self
	}
}
