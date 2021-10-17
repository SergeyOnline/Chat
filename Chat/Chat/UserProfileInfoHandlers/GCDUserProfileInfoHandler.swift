//
//  GCDUserSettingsHandler.swift
//  Chat
//
//  Created by Сергей on 17.10.2021.
//

import Foundation
import UIKit

/*
public enum ImageOperationError: Error {
	case badOperationFinnished
	case badLoading
	case badRotation
}

public func syncImageLoad(imageURL: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
	if let data = try? Data(contentsOf: imageURL),
	   let image = UIImage(data: data) {
		sleep(2)
		completion(.success(image))
	} else {
		completion(.failure(ImageOperationError.badLoading))
	}
}
 */


class GCDUserProfileInfoHandler {
	private let queue = DispatchQueue.global(qos: .utility)
	
	func saveOwnerInfo(owner: Owner, complition: @escaping (Error?) -> Void) {
		queue.async {
			do {
				let fileManager = FileManager.default
				let fileUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("userSittings.json")
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
				let fileUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("userSittings.json")
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
				let fileUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("userImage.jpg")
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
				let fileUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("userImage.jpg")
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
	
//	func loadImage(imageURL: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
//		queue.async {
//			syncImageLoad(imageURL: imageURL) { result in
//				DispatchQueue.main.async { completion(result) }
//			}
//		}
//	}
}
