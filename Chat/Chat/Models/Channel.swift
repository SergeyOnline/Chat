//
//  Channel.swift
//  Chat
//
//  Created by Сергей on 24.10.2021.
//

import Foundation

struct Channel: Codable {
	let identifier: String
	let name: String
	let lastMessage: String?
	let lastActivity: Date?
}
