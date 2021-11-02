//
//  DataManager.swift
//  Chat
//
//  Created by Сергей on 02.11.2021.
//

import UIKit
import CoreData

final class DataManager {
	
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
	
	func loadChannelsWhithPredicate(_ predicate: NSPredicate? = nil) -> [DBChannel] {
		var channels: [DBChannel] = []
		
		let context = persistentContainer.viewContext
		let request: NSFetchRequest<DBChannel> = DBChannel.fetchRequest()
//		let predicate = NSPredicate(format: "identifier like %@", "Apla1LdEILaogpJTph5a")
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
	
//	func saveContext() {
//		let context = persistentContainer.viewContext
//		if context.hasChanges {
//			do {
//				try context.save()
//			} catch {
//				let error = error as NSError
//				fatalError("Unresolved error \(error), \(error.userInfo)")
//			}
//		}
//	}
	
	func logChannelsContent() {
		#if DEBUG
		if CommandLine.arguments.contains("DEBUG_LOG_CHANNELS_CONTENT") {
			print("----------------------------------------------------------")
			print("*************** Core Data Channels content ***************")
			print("----------------------------------------------------------")
			let channels = loadChannelsWhithPredicate()
			for channel in channels {
				print("Name\t\t: " + (channel.name ?? "--empty--"))
				print("Identifier\t: " + (channel.identifier ?? "--empty--"))
				if #available(iOS 15.0, *) {
					print("Date\t\t: " + (channel.lastActivity?.formatted(date: .numeric, time: .shortened) ?? "--empty--"))
				}
				print("Last message: \(channel.lastMessage ?? "--empty--")")
				print("----------------------------------")
			}
			print("Count: \(channels.count)")
		}
		#endif
	}
}
