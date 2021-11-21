//
//  ProfileViewController+TextFieldDelegate.swift
//  Chat
//
//  Created by Сергей on 21.11.2021.
//

import UIKit

extension ProfileViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		infoTextView.becomeFirstResponder()
		let insertionPoint = NSRange(location: infoTextView.text.count, length: 0)
		infoTextView.selectedRange = insertionPoint
		return true
	}
}
