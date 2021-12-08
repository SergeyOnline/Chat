//
//  ChannelsService.swift
//  Chat
//
//  Created by Сергей on 18.11.2021.
//

import Foundation
import CoreData
import Firebase

protocol IChannelsService {
	init(persistentContainer: NSPersistentContainer)
	func saveChannels(_ channels: [DocumentChange])
	func removeChannel(_ channel: DocumentChange)
	func loadChannels(_ predicate: NSPredicate?) -> [DBChannel]
}

final class ChannelsService: IChannelsService {
	
	private enum Constants {
		static let channelKeyName = "name"
		static let channelKeyLastMessage = "lastMessage"
		static let channelKeyLastActivity = "lastActivity"
	}
	
	private let persistentContainer: NSPersistentContainer
	
	required init(persistentContainer: NSPersistentContainer) {
		self.persistentContainer = persistentContainer
	}
	
	func saveChannels(_ channels: [DocumentChange]) {
		persistentContainer.performBackgroundTask({ context in
			context.mergePolicy = NSMergePolicy.overwrite
			channels.forEach { channel in
				let newChannel = DBChannel(context: context)
				let data = channel.document.data()
				newChannel.identifier = channel.document.documentID
				newChannel.name = (data[Constants.channelKeyName] as? String) ?? ""
				newChannel.lastMessage = data[Constants.channelKeyLastMessage] as? String
				newChannel.lastActivity = (data[Constants.channelKeyLastActivity] as? Timestamp)?.dateValue()
			}
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
}
