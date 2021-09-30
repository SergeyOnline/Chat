//
//  ProfileLabel.swift
//  Chat
//
//  Created by Сергей on 25.09.2021.
//

import UIKit

class ProfileLabel: UILabel {

	convenience init(text: String, font: UIFont) {
		self.init()
		self.text = text
		self.font = font
		self.translatesAutoresizingMaskIntoConstraints = false
	}

}
