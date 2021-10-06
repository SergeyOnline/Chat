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
	
	static let context = ["Да", "Ок", "Как дела? \nЧто делаешь?", "В порядке", "Вчера был в аду\nСам как?", "Не знаю", "Нет", "Ну если подумать...\nНаверное не плохо.\nСам решай", "Меня нет", "Жив, здоров", "Был там\nНе очень\nДумаю есть места получше\nХотя...\nНе знаю...", "Купил слона?\nПочем?", "около 1000", "Неплохо.\nНо ты можешь лучше", "Кто знает...", "Лол))\nИ Как?", "А где?", "Приходи сегодня.\nПопробуем приготовить.", "Это не точно", "Да как так то?!?", "У тебя юудут проблемы, точно говорю", "В пол 5\n Или 6\n Посмотрим", "Ботинок", "Сам такой\nОбидка", "Дурень\nВсе только начинается", "Где-то", "Не хочу говорить\nПозднее может", "Ну так то да, такое себе", "Я дома\nНе занят", "Да\nНет", "Во сколько?\nЯ подумаю\nТочно надо?\nЯ просто занят", "Выходи", "Вышел", "А у тебя есть?", "Ага))", "Не точно\nНу был там, да", "Я в столовке\nТебе взять еды?", "Если пойдешь еще раз, то меня позови", "Привет!", "Здоров"]
	
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
		let count = arc4random_uniform(40)
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

