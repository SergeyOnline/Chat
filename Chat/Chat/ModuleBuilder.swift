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
		let view = AvatarViewController()
		let presenter = AvatarPresenter(view: view)
		view.presenter = presenter
		return view
	}
}

