//
//  User.swift
//  Chat
//
//  Created by Сергей on 03.10.2021.
//

import UIKit

class User {
	
	var firstName: String
	var lastName: String?
	
	var message: [Date: String]
	var online: Bool
	var hasUnreadMessages: Bool
	var imageView: UIImageView!
	
	var fullName: String {
		get {
			return firstName + " " + (lastName ?? "")
		}
		
		set {
			if newValue.isEmpty {
				return
			}
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
	
	init(firstName: String, lastName: String?, message: [Date: String] = [:], online: Bool, hasUnreadMessages: Bool) {
		self.firstName = firstName
		self.lastName = lastName
		self.message = message
		self.online = online
		self.hasUnreadMessages = hasUnreadMessages
		imageView = UserImageView(labelTitle: initials, labelfontSize: 20)
	}
}

