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

extension String {
	var numberOfWords: Int {
		var count = 0
		let range = startIndex..<endIndex
		enumerateSubstrings(in: range, options: [.byWords, .substringNotRequired, .localized], { _, _, _, _ -> Void in
			count += 1
		})
		return count
	}
}

extension Bundle {
	var pixabayApiKey: String {
		return object(forInfoDictionaryKey: "Pixabay API key") as? String ?? ""
	}
	
	var pixabayHost: String {
		return object(forInfoDictionaryKey: "Pixabay host") as? String ?? ""
	}
	
	var pixabayParameters: String {
		return object(forInfoDictionaryKey: "Pixabay parameters") as? String ?? ""
	}
}
