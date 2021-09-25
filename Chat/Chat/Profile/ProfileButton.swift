//
//  ProfileButton.swift
//  Chat
//
//  Created by Сергей on 25.09.2021.
//

import UIKit

class ProfileButton: UIButton {
	
	override var isHighlighted: Bool {
		didSet {
			UIView.animate(withDuration: self.isHighlighted ? 0 : 0.3, delay: 0.0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
				self.setTitleColor(.systemBlue.withAlphaComponent(self.isHighlighted ? 0.4 : 1), for: .normal)
			})
		}
	}
	
	convenience init(title: String, fontSize: CGFloat) {
		self.init()
		self.setTitle(title, for: .normal)
		self.setTitleColor(.systemBlue, for: .normal)
		self.titleLabel?.font = UIFont.systemFont(ofSize: 16)
		self.translatesAutoresizingMaskIntoConstraints = false
	}
	
}
