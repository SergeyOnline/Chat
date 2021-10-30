//
//  User.swift
//  Chat
//
//  Created by Сергей on 03.10.2021.
//

import UIKit

class User {
	
	static var idGenerator = 1
	
	var firstName: String
	var lastName: String?
	var id: Int
	var messages: [Message]?
	var online: Bool
	var hasUnreadMessages: Bool {
		get {
			guard let allMessages = messages else { return false }
			for message in allMessages {
				if message.unread {
					return true
				}
			}
			return false
		}
	}
	
	var imageView: UIImageView?
	
	var fullName: String {
		get {
			return firstName + " " + (lastName ?? "")
		}
		
		set {
			if newValue.isEmpty { return }
			let arr = newValue.components(separatedBy: " ")
			firstName = arr[0]
			if arr.count > 1 {
				lastName = arr[1]
			}
		}
	}
	
	var initials: String {
		get {
			return (firstName.first?.uppercased() ?? "") + (lastName?.first?.uppercased() ?? "")
		}
	}
	
	init(firstName: String, lastName: String?, messages: [Message]? = nil, online: Bool) {
		self.firstName = firstName
		self.lastName = lastName
		self.messages = messages
		self.online = online
		self.id = User.idGenerator
		User.idGenerator += 1
		imageView = UserImageView(labelTitle: initials, labelfontSize: 20)
	}
}

