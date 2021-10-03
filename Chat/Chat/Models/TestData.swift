//
//  TestData.swift
//  Chat
//
//  Created by Сергей on 03.10.2021.
//

import Foundation

struct TestData {
	static let lastNames = ["Walker", "Carter", "Morris", "Ramirez", "Barnes", "Simmons", "Gray", "Campbell", "Lee", "Brown", "James", "Kelly", "Perry", "Henderson", "Gray", "Parker", "Bennett", "Williams", "Hayes", "Wilson", "Powell", "Davis", "Rodriguez", "Henderson", "Long", "Evans", "Patterson", "Stewart", "Hill", "Cox", "Foster", "Cooper", "Martinez", "Parker", "Johnson", "Williams", "Mitchell", "Barnes", "Allen", "Gonzales", "Price", "Patterson", "Cox", "Murphy", "Gray", "Flores", "Rodriguez", "Martinez", "Wright", "Perez"]
	
	static let firstNames = ["Armando", "Bronson", "Bryson", "Dante", "Dominic", "Everett", "Hugo", "Isaak", "Issac", "Jace", "Kenley", "Knox", "Milo", "Octavio", "Osiris", "Ozzy", "Quinten", "Ricardo", "Roman", "Roy", "Westley", "Xavion", "Yehoshua", "Yousef", "Zechariah", "Ruth", "Paula", "Wilfreda", "Zaida", "Undine", "Clara", "Orabelle", "Yuki", "Laila", "Viktoria", "Vanessa", "Selena", "Thea", "Xanthia", "Fabiana", "Heidy", "Janelle", "Belen", "Bianca", "Praise", "Elaina", "Cali", "Skyla", "Veronika", "Zaira"]
	
	static let context = ["Sed ut perspici\natis unde omnis", " iste natus error sit", " voluptatem accusantium \ndoloremque laudantium, totam", " rem aperiam, eaque", " ipsa quae\n ab illo", " inventore veritatis", " et", " quasi architecto \nbeatae\n vitae", " dicta sunt ", "explicabo.", " Nemo enim ipsam\n voluptatem \nquia voluptas \nsit \naspernatur", " aut odit aut \nfugit, sed", " quia consequuntur ", "magni dolores\n eos qui ", "ratione voluptatem ", "sequi\n nesciunt. ", "Neque porro", " quisquam est, qui \ndolorem", " ipsum", " quia dolor", " sit amet, consectetur, adipisci", " velit, sed quia\n non\n numquam", " eius modi tempora", " incidunt\n ut labore", " et dolore magnam \naliquam", " quaerat ", "voluptatem. \nUt enim ad ", "minima veniam, ", "quis \nnostrum exercitationem", " ullam corporis\n suscipit l", "aboriosam, \nnisi \nut aliquid \nex ea commodi consequatur?", " Quis autem vel eum", " iure \nreprehenderit", " qui in ea voluptate velit", " esse quam nihil", " molestiae \nconsequatur, vel", " illum qui \ndolorem eum", " fugiat quo voluptas nulla pariatur?"]
	
	static func gFirstName() -> String {
		return firstNames[Int(arc4random_uniform(UInt32(firstNames.count)))]
	}
	
	static func gLastName() -> String {
		return lastNames[Int(arc4random_uniform(UInt32(lastNames.count)))]
	}
	
	static func gDate() -> Date {
		let num = arc4random_uniform(100)
		var offset = 0
		switch num {
		case ...45: offset = Int(arc4random_uniform(1_000_000_000))
		case 55...: offset = Int(arc4random_uniform(86_400))
		default: break
		}
		return Date(timeInterval: TimeInterval(-offset), since: Date())
	}
	static func gMassage() -> [Date: String] {
		var arr: [Date: String] = [:]
		let count = arc4random_uniform(5)
		for _ in 0...count {
			arr[gDate()] = context[Int(arc4random_uniform(UInt32(context.count)))]
		}
		return arr
	}
	
	static func gBool() -> Bool {
		let num = arc4random_uniform(100)
		if num > 50 {
			return true
		} else {
			return false
		}
	}
	
	static func ghasUnreadMessages() -> Bool {
		let num = arc4random_uniform(100)
		if num > 50 {
			return true
		} else {
			return false
		}
	}
	
	static let users = [User(firstName: "Sergey", lastName: "Gryaznov", message: [Date(): "My test message"], online: true, hasUnreadMessages: false),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages()),
						User(firstName: gFirstName(), lastName: gLastName(), message: gMassage(), online: gBool(), hasUnreadMessages: ghasUnreadMessages())]
}

