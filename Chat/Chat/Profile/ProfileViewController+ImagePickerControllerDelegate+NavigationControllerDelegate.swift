//
//  ProfileViewController+ImagePickerControllerDelegate+NavigationControllerDelegate.swift
//  Chat
//
//  Created by Сергей on 28.11.2021.
//

import UIKit

extension ProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
		picker.dismiss(animated: true, completion: nil)
		imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
		guard let image = imageView.image else { return }
		userProfileHandlerGCD.saveOwnerImage(image: image) { error in
			DispatchQueue.main.async {
				if let error = error {
					print("ERROR: \(error.localizedDescription)")
				} else {
					self.completion()
				}
			}
		}
	}
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}
