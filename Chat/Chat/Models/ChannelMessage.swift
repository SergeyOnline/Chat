//
//  ChannelMessage.swift
//  Chat
//
//  Created by Сергей on 24.10.2021.
//

import Foundation
import Firebase

struct ChannelMessage {
	let content: String
	let created: Date
	let senderId: String
	let senderName: String
}

extension ChannelMessage {
	var toDict: [String: Any] {
		return ["content": content,
				"created": created,
				"senderId": senderId,
				"senderName": senderName]
	}
	
 }
