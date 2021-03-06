//
//  ModuleBuilder.swift
//  Chat
//
//  Created by Сергей on 19.11.2021.
//

import Foundation
import UIKit

protocol Assembly {
	static func createImagePickerModule() -> UIViewController
}

final class ModuleAssembly: Assembly {
	static func createImagePickerModule() -> UIViewController {
		let view = ImagePickerViewController()
		let networkService = NetworkService(imageLoaderAPI: ImageLoaderAPI())
//		let networkService = NetworkService(apiKey: APIKey.key)
		let presenter = ImagePickerPresenter(view: view, networkService: networkService)
		view.presenter = presenter
		return view
	}
	
	static func createConversationMessgesNodule(forChannel channel: DBChannel?) -> UIViewController {
		let view = ConversationViewController()
		let networkService = NetworkService(imageLoaderAPI: ImageLoaderAPI())
//		let networkService = NetworkService(apiKey: APIKey.key)
		let presenter = ConversationMessagesPresenter(view: view, networkService: networkService, dataManager: DataManager.shared, channel: channel)
		view.presenter = presenter
		return view
	}
}
