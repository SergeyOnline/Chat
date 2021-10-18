//
//  GCDUserSettingsHandler.swift
//  Chat
//
//  Created by Сергей on 17.10.2021.
//

import Foundation
import UIKit

class GCDUserProfileInfoHandler {
	
	private enum FileKeys {
		static let userInfo = "userInfo.json"
		static let userImage = "userImage.jpg"
		static let theme = "theme.txt"
	}
	
	private let queue = DispatchQueue.global(qos: .utility)
	
	func saveOwnerInfo(owner: Owner, complition: @escaping (Error?) -> Void) {
		queue.async {
			do {
				let fileManager = FileManager.default
				let fileUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(FileKeys.userInfo)
				try JSONEncoder().encode(owner).write(to: fileUrl)
				sleep(4)
				DispatchQueue.main.async {
					complition(nil)
				}
			} catch {
				DispatchQueue.main.async {
					print(error)
					complition(error)
				}
			}
		}
	}
	
	func loadOwnerInfo(complition: @escaping (Result<Owner, Error>) -> Void) {
		queue.async {
			do {
				let fileManager = FileManager.default
				let fileUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(FileKeys.userInfo)
				let data = try Data(contentsOf: fileUrl)
				let owner = try JSONDecoder().decode(Owner.self, from: data)
				DispatchQueue.main.async {
					complition(.success(owner))
				}
			} catch {
				DispatchQueue.main.async {
					print(error)
					complition(.failure(error))
				}
			}
		}
	}
	
	func saveOwnerImage(image: UIImage?, complition: @escaping (Error?) -> Void) {
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
					complition(nil)
				}
			} catch {
				DispatchQueue.main.async {
					complition(error)
				}
			}
		}
	}
	
	func loadOwnerImage(complition: @escaping (Result<UIImage?, Error>) -> Void) {
		queue.async {
			do {
				let fileManager = FileManager.default
				let fileUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(FileKeys.userImage)
				let data = try Data(contentsOf: fileUrl)
				let image = UIImage(data: data)
				DispatchQueue.main.async {
					complition(.success(image))
				}
			} catch {
				DispatchQueue.main.async {
					complition(.failure(error))
				}
			}
		}
	}
	
	func saveTheme(themeId: Int, complition: @escaping (Error?) -> Void) {
		queue.async {
			do {
				let fileManager = FileManager.default
				let fileUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(FileKeys.theme)
				let stringThemeId = String(themeId)
				if let data = stringThemeId.data(using: .utf8) {
					try data.write(to: fileUrl)
				}
				DispatchQueue.main.async {
					complition(nil)
				}
			} catch {
				DispatchQueue.main.async {
					complition(error)
				}
			}
		}
	}
	
	func loadTheme(complition: @escaping (Result<Int, Error>) -> Void) {
		queue.async {
			do {
				let fileManager = FileManager.default
				let fileUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(FileKeys.theme)
				let data = try Data(contentsOf: fileUrl)
				let stringThemeId: String = String(data: data, encoding: .utf8) ?? "0"
				let themeId: Int = Int(stringThemeId) ?? 0
				DispatchQueue.main.async {
					complition(.success(themeId))
				}
			} catch {
				DispatchQueue.main.async {
					complition(.failure(error))
				}
			}
		}
	}
}
