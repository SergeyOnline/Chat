//
//  CustomStackView.swift
//  Chat
//
//  Created by Сергей on 03.10.2021.
//

import UIKit

class CustomStackView: UIStackView {
	
	convenience init(axis: NSLayoutConstraint.Axis, distribution: UIStackView.Distribution, spacing: CGFloat = 0) {
		self.init()
		self.axis = axis
		self.distribution = distribution
		self.spacing = spacing
	}
	
}
