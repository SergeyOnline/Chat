//
//  ImagesList.swift
//  Chat
//
//  Created by Сергей on 19.11.2021.
//

import Foundation

struct ImagesList: Decodable {
	let hits: [ImageInfo]?
}

struct ImageInfo: Decodable {
	let id: Int?
	let imageURL: String?
	
	private enum CodingKeys: String, CodingKey {
		case id
		case imageURL = "webformatURL"
	}
}
