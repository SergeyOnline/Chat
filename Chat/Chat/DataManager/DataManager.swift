//
//  DataManager.swift
//  Chat
//
//  Created by Сергей on 02.11.2021.
//

import UIKit
import CoreData
import Firebase

protocol DataManagerProtocol {
	var persistentContainer: NSPersistentContainer { get }
	var channelsService: IChannelsService { get }
	var messagesService: IMessagesService { get }
	
}

final class DataManager: DataManagerProtocol {
	
	static var shared: DataManager = {
		let instance = DataManager()
		return instance
	}()
	
	var persistentContainer: NSPersistentContainer
	var channelsService: IChannelsService
	var messagesService: IMessagesService
	
	private init() {
		persistentContainer = NSPersistentContainer(name: "Chat")
		persistentContainer.loadPersistentStores { _, error in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		}
		persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
		channelsService = ChannelsService(persistentContainer: persistentContainer)
		messagesService = MessagesService(persistentContainer: persistentContainer)
	}
}

extension DataManager: NSCopying {
	func copy(with zone: NSZone? = nil) -> Any {
		return self
	}
}
