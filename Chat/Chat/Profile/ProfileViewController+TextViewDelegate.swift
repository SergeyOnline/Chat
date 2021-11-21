//
//  ProfileViewController+TextViewDelegate.swift
//  Chat
//
//  Created by Сергей on 21.11.2021.
//

import UIKit

extension ProfileViewController: UITextViewDelegate {
	func textViewDidChange(_ textView: UITextView) {
		guard let text = textView.text else { return }
		if text.isEmpty {
			changeSaveButtonsStatusTo(.disable)
		} else {
			changeSaveButtonsStatusTo(.enable)
		}
	}
}
