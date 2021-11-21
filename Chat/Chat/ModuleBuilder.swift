//
//  ModuleBuilder.swift
//  Chat
//
//  Created by Сергей on 19.11.2021.
//

import Foundation
import UIKit

protocol Assembly {
	static func createAvatarModule() -> UIViewController
}

class ModuleAssembly: Assembly {
	static func createAvatarModule() -> UIViewController {
		let view = ImagePickerViewController()
		let networkService = NetworkService()
		let presenter = ImagePickerPresenter(view: view, networkService: networkService)
		view.presenter = presenter
		return view
	}
}
