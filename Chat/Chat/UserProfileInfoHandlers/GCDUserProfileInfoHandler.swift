//
//  GCDUserSettingsHandler.swift
//  Chat
//
//  Created by Сергей on 17.10.2021.
//

import Foundation
import UIKit

final class GCDUserProfileInfoHandler: UserProfileInfoHandlerProtocol {
	
	private let queue = DispatchQueue.global(qos: .utility)
	
	func saveOwnerInfo(owner: Owner, completion: @escaping (Error?) -> Void) {
		queue.async {
			do {
				let fileManager = FileManager.default
				let fileUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(FileKeys.userInfo)
				try JSONEncoder().encode(owner).write(to: fileUrl)
				DispatchQueue.main.async {
					completion(nil)
				}
			} catch {
				DispatchQueue.main.async {
					print(error)
					completion(error)
				}
			}
		}
	}
	
	func loadOwnerInfo(completion: @escaping (Result<Owner, Error>) -> Void) {
		queue.async {
			do {
				let fileManager = FileManager.default
				let fileUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(FileKeys.userInfo)
				let data = try Data(contentsOf: fileUrl)
				let owner = try JSONDecoder().decode(Owner.self, from: data)
				DispatchQueue.main.async {
					completion(.success(owner))
				}
			} catch {
				DispatchQueue.main.async {
					print(error)
					completion(.failure(error))
				}
			}
		}
	}
	
	func saveOwnerImage(image: UIImage?, completion: @escaping (Error?) -> Void) {
		queue.async {
			do {
				let fileManager = FileManager.default
				let fileUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(FileKeys.userImage)
				if let image = image {
					let imageData = image.jpegData(compressionQuality: 0.3)
					try imageData?.write(to: fileUrl)
				} else {
					try fileManager.removeItem(at: fileUrl)
				}
				DispatchQueue.main.async {
					completion(nil)
				}
			} catch {
				DispatchQueue.main.async {
					completion(error)
				}
			}
		}
	}
	
	func loadOwnerImage(completion: @escaping (Result<UIImage?, Error>) -> Void) {
		queue.async {
			do {
				let fileManager = FileManager.default
				let fileUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(FileKeys.userImage)
				let data = try Data(contentsOf: fileUrl)
				let image = UIImage(data: data)
				DispatchQueue.main.async {
					completion(.success(image))
				}
			} catch {
				DispatchQueue.main.async {
					completion(.failure(error))
				}
			}
		}
	}
	
	func saveTheme(themeId: Int, completion: @escaping (Error?) -> Void) {
		queue.async {
			do {
				let fileManager = FileManager.default
				let fileUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(FileKeys.theme)
				let stringThemeId = String(themeId)
				if let data = stringThemeId.data(using: .utf8) {
					try data.write(to: fileUrl)
				}
				DispatchQueue.main.async {
					completion(nil)
				}
			} catch {
				DispatchQueue.main.async {
					completion(error)
				}
			}
		}
	}
	
	func loadTheme(completion: @escaping (Result<Int, Error>) -> Void) {
		queue.async {
			do {
				let fileManager = FileManager.default
				let fileUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(FileKeys.theme)
				let data = try Data(contentsOf: fileUrl)
				let stringThemeId: String = String(data: data, encoding: .utf8) ?? "0"
				let themeId: Int = Int(stringThemeId) ?? 0
				DispatchQueue.main.async {
					completion(.success(themeId))
				}
			} catch {
				DispatchQueue.main.async {
					completion(.failure(error))
				}
			}
		}
	}
}
