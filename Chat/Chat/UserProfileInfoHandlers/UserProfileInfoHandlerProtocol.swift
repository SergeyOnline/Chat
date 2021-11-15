//
//  UserProfileInfoHandlerProtocol.swift
//  Chat
//
//  Created by Сергей on 18.10.2021.
//

import UIKit

protocol UserProfileInfoHandlerProtocol {
	func saveOwnerInfo(owner: Owner, completion: @escaping (Error?) -> Void)
	func loadOwnerInfo(completion: @escaping (Result<Owner, Error>) -> Void)
	func saveOwnerImage(image: UIImage?, completion: @escaping (Error?) -> Void)
	func loadOwnerImage(completion: @escaping (Result<UIImage?, Error>) -> Void)
}
