//
//  AvatarPresenter.swift
//  Chat
//
//  Created by Сергей on 19.11.2021.
//

import Foundation

protocol AvatarViewProtocol: AnyObject {
	func cancellButtonTapped()
}

protocol AvatarPresenterProtocol: AnyObject {
	init(view: AvatarViewProtocol)
	func cancellButtonTapped()
}

class AvatarPresenter: AvatarPresenterProtocol {
	
	let view: AvatarViewProtocol
	
	required init(view: AvatarViewProtocol) {
		self.view = view
	}
	
	func cancellButtonTapped() {
		view.cancellButtonTapped()
	}

}
