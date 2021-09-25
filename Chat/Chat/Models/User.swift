//
//  User.swift
//  Chat
//
//  Created by Сергей on 25.09.2021.
//

struct User {
	var firstName = "Sergei"
	var lastName = "Gryaznov"
	var info = "iOS Developer, humble genius\nKazan, Russia"
	
	var initials: String {
		get {
			return (firstName.first?.uppercased() ?? "") + (lastName.first?.uppercased() ?? "")
		}
	}
	
	var fullName: String {
		get {
			return firstName + " " + lastName
		}
	}
}
