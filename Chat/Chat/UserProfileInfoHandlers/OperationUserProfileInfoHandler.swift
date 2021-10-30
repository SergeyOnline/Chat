//
//  OperationUserProfileInfoHandler.swift
//  Chat
//
//  Created by Сергей on 18.10.2021.
//

import UIKit

final class OperationUserProfileInfoHandler: UserProfileInfoHandlerProtocol {
	
	private let queue = OperationQueue()
	
	func saveOwnerInfo(owner: Owner, completion: @escaping (Error?) -> Void) {
		let saveOwnerInfoOperation = SaveOwnerInfoOperation(owner: owner)
		saveOwnerInfoOperation.completionBlock = {
			OperationQueue.main.addOperation {
				if let error = saveOwnerInfoOperation.error {
					completion(error)
				} else {
					completion(nil)
				}
			}
		}
		queue.addOperation(saveOwnerInfoOperation)
	}
	
	func loadOwnerInfo(completion: @escaping (Result<Owner, Error>) -> Void) {
		let loadOwnerInfoOperation = LoadOwnerInfoOperation()
		loadOwnerInfoOperation.completionBlock = {
			OperationQueue.main.addOperation {
				if let result = loadOwnerInfoOperation.result {
					completion(result)
				}
			}
		}
		queue.addOperation(loadOwnerInfoOperation)
	}
	
	func saveOwnerImage(image: UIImage?, completion: @escaping (Error?) -> Void) {
		let saveOwnerInfoOperation = SaveOwnerImageOperation(image: image)
		saveOwnerInfoOperation.completionBlock = {
			OperationQueue.main.addOperation {
				if let error = saveOwnerInfoOperation.error {
					completion(error)
				} else {
					completion(nil)
				}
			}
		}
		queue.addOperation(saveOwnerInfoOperation)
	}
	
	func loadOwnerImage(completion: @escaping (Result<UIImage?, Error>) -> Void) {
		let loadOwnerInfoOperation = LoadOwnerImageOperation()
		loadOwnerInfoOperation.completionBlock = {
			OperationQueue.main.addOperation {
				if let result = loadOwnerInfoOperation.result {
					completion(result)
				}
			}
		}
		queue.addOperation(loadOwnerInfoOperation)
	}
}

private class AsyncOperation: Operation {
	
	public enum State: String {
		case ready, executing, finished
		
		var keyPath: String {
			return "is" + rawValue.capitalized
		}
	}
	
	var state = State.ready {
		willSet {
			willChangeValue(forKey: newValue.keyPath)
			willChangeValue(forKey: state.keyPath)
		}
		didSet {
			didChangeValue(forKey: oldValue.keyPath)
			didChangeValue(forKey: state.keyPath)
		}
	}
}

extension AsyncOperation {
	override var isReady: Bool {
		return super.isReady && state == .ready
	}
	
	override var isExecuting: Bool {
		return state == .executing
	}
	
	override var isFinished: Bool {
		return state == .finished
	}
	
	override var isAsynchronous: Bool {
		return true
	}
	
	override func start() {
		if isCancelled {
			state = .finished
			return
		}
		
		main()
		state = .executing
	}
	
	override func cancel() {
		super.cancel()
		state = .finished
	}
}

private func syncSaveOwnerInfo(owner: Owner, completion: @escaping (Error?) -> Void) {
	do {
		let fileManager = FileManager.default
		let fileUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(FileKeys.userInfo)
		try JSONEncoder().encode(owner).write(to: fileUrl)
		completion(nil)
	} catch {
		completion(error)
	}
}

private func syncLoadOwnerInfo(completion: @escaping (Result<Owner, Error>) -> Void) {
	do {
		let fileManager = FileManager.default
		let fileUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(FileKeys.userInfo)
		let data = try Data(contentsOf: fileUrl)
		let owner = try JSONDecoder().decode(Owner.self, from: data)
		completion(.success(owner))
	} catch {
		completion(.failure(error))
	}
	
}

private func syncSaveOwnerImage(image: UIImage?, completion: @escaping (Error?) -> Void) {
	do {
		let fileManager = FileManager.default
		let fileUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(FileKeys.userImage)
		if let image = image {
			let imageData = image.jpegData(compressionQuality: 0.3)
			try imageData?.write(to: fileUrl)
		} else {
			try fileManager.removeItem(at: fileUrl)
		}
		completion(nil)
	} catch {
		completion(error)
	}
}

private func syncLoadOwnerImage(completion: @escaping (Result<UIImage?, Error>) -> Void) {
	do {
		let fileManager = FileManager.default
		let fileUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(FileKeys.userImage)
		let data = try Data(contentsOf: fileUrl)
		let image = UIImage(data: data)
		completion(.success(image))
	} catch {
		completion(.failure(error))
	}
}

private class SaveOwnerInfoOperation: AsyncOperation {
	private let owner: Owner
	private(set) var error: Error?
	
	init(owner: Owner) {
		self.owner = owner
		super.init()
	}
	
	override func main() {
		if isCancelled {
			state = .finished
			return
		}
		syncSaveOwnerInfo(owner: owner) { error in
			self.error = error
			self.state = .finished
		}
	}
}

private class SaveOwnerImageOperation: AsyncOperation {
	private let image: UIImage?
	private(set) var error: Error?
	
	init(image: UIImage?) {
		self.image = image
		super.init()
	}
	
	override func main() {
		if isCancelled {
			state = .finished
			return
		}
		syncSaveOwnerImage(image: image) { error in
			self.error = error
			self.state = .finished
		}
	}
}

private class LoadOwnerInfoOperation: AsyncOperation {
	
	private(set) var result: Result<Owner, Error>?
	
	override func main() {
		if isCancelled {
			state = .finished
			return
		}
		syncLoadOwnerInfo { result in
			self.result = result
			self.state = .finished
		}
	}
}

private class LoadOwnerImageOperation: AsyncOperation {
	
	private(set) var result: Result<UIImage?, Error>?
	
	override func main() {
		if isCancelled {
			state = .finished
			return
		}
		syncLoadOwnerImage { result in
			self.result = result
			self.state = .finished
		}
	}
}
