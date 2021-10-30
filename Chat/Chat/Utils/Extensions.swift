//
//  Extensions.swift
//  Chat
//
//  Created by Сергей on 30.10.2021.
//

import UIKit

extension UIAlertController {
	func setThemeOptions(viewBackground: UIColor, titleColor: UIColor, buttonsBackground: UIColor, tintColor: UIColor) {
		
		if let title = title {
			setValue(NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor: titleColor]), forKey: "attributedTitle")
		}
		if let message = message {
			setValue(NSAttributedString(string: message, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
																	  NSAttributedString.Key.foregroundColor: titleColor]), forKey: "attributedMessage")
		}
		view.backgroundColor = viewBackground
		view.layer.cornerRadius = 15
		if let firstSubview = view.subviews.first, let alertContentView = firstSubview.subviews.first {
			for view in alertContentView.subviews {
				view.backgroundColor = buttonsBackground.withAlphaComponent(0.85)
			}
		}
		view.tintColor = tintColor
	}
}
