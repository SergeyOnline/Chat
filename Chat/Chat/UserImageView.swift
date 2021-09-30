//
//  UserImageView.swift
//  Chat
//
//  Created by Сергей on 25.09.2021.
//

import UIKit

class UserImageView: UIImageView {

	init(labelTitle: String, labelfontSize: CGFloat) {
		super.init(image: nil)
		self.backgroundColor = UIColor(red: 0.894, green: 0.908, blue: 0.17, alpha: 1)
		self.clipsToBounds = true
		self.translatesAutoresizingMaskIntoConstraints = false
		
		let initialLabel = ProfileLabel(text: labelTitle, font: UIFont.systemFont(ofSize: labelfontSize))
		self.addSubview(initialLabel)
		initialLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		initialLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}
