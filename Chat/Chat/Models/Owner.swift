//
//  User.swift
//  Chat
//
//  Created by Сергей on 25.09.2021.
//

import UIKit

struct Owner: Codable {
	var firstName = "Sergei"
	var lastName = "G."
	var info = "iOS Developer\nKazan, Russia"
	
	var initials: String {
		return (firstName.first?.uppercased() ?? "") + (lastName.first?.uppercased() ?? "")
	}
	
	var fullName: String {
		get {
			return firstName + " " + lastName
		}
		set {
			if newValue.isEmpty { return }
			let arr = newValue.components(separatedBy: " ")
			firstName = arr[0]
			if arr.count > 1 {
				lastName = arr[1]
			} else {
				lastName = ""
			}
		}
	}
	
	// MARK: - default owner name
//	init() {
//		fullName = UIDevice.current.name
//	}
	
}
