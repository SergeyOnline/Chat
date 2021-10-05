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
	static func gMassage() -> [Message]? {
		var arr: [Message] = []
		let count = arc4random_uniform(25)
		for _ in 0...count {
			let text = context[Int(arc4random_uniform(UInt32(context.count)))]
			arr.append(Message(body: text, date: gDate(), unread: gBool(), ownerID: gBool() ? User.idGenerator : 0))
		}
		if !arr.isEmpty {
			arr.sort { $0.unread && !$1.unread }
			
			var unread = arr.filter { $0.unread }
			var other = arr.filter { !$0.unread }
			unread = unread.sorted(by: { u1, u2 in
				return u1.date < u2.date
			})
			other = other.sorted(by: { u1, u2 in
				return u1.date < u2.date
			})
			arr = unread + other
//			for v in arr {
//				print("\(v.date.description): \(v.unread ? "unread" : "-")")
//			}
//			print("---------------------------")
		}
		return arr.isEmpty ? nil : arr
	}
	
	static func gBool() -> Bool {
		let num = arc4random_uniform(100)
		if num > 50 {
			return true
		} else {
			return false
		}
	}
	
	static let users = [User(firstName: "Sergey", lastName: "Gryaznov", messages: [Message(body: "My test message", date: Date(timeInterval: 10, since: Date()), unread: true, ownerID: User.idGenerator)], online: true),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: gMassage(), online: gBool()),
						User(firstName: gFirstName(), lastName: gLastName(), messages: nil, online: gBool())]
}

