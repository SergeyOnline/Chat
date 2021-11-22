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

class ModuleAssembly: Assembly {
	static func createImagePickerModule() -> UIViewController {
		let view = ImagePickerViewController()
		let networkService = NetworkService()
		let presenter = ImagePickerPresenter(view: view, networkService: networkService)
		view.presenter = presenter
		return view
	}
}
