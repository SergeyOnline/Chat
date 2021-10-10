//
//  ProfileViewController.swift
//  Chat
//
//  Created by Сергей on 24.09.2021.
//

import UIKit

final class ProfileViewController: UIViewController {
	
	private enum LocalizeKeys {
		static let cameraAction = "cameraAction"
		static let gallaryAction = "gallaryAction"
		static let deleteAction = "deleteAction"
		static let profileLabel = "profileLabel"
		static let closeButtonTitle = "closeButtonTitle"
		static let saveButtonTitle = "saveButtonTitle"
		static let editButtonTitle = "editButtonTitle"
	}
	
	var closeButton: UIButton!
	var imageView: UIImageView!
	var user = Owner()
	var saveButton: UIButton!
	var editButton: UIButton!
	
	private var picker = UIImagePickerController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
//		view.backgroundColor = (traitCollection.userInterfaceStyle == .dark) ? UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1) : .white
		view.backgroundColor = TableViewCellAppearance.backgroundColor.uiColor()
		setupElements()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	//MARK: - Init
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	//MARK: - Actions
	
	@objc func closeButtonAction(_ sender: UIButton) {
		navigationController?.popViewController(animated: true)
		dismiss(animated: true, completion: nil)
	}
	
	@objc func saveButtonAction(_ sender: UIButton) {
		print("Save button tapped")
	}
	
	@objc func editButtonAction(_ sender: UIButton) {
		
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let cameraAction = UIAlertAction(title: NSLocalizedString(LocalizeKeys.cameraAction, comment: ""), style: .default) { _ in
			self.openCamera()
		}
		
		let gallaryAction = UIAlertAction(title: NSLocalizedString(LocalizeKeys.gallaryAction, comment: ""), style: .default) { _ in
			self.openGallary()
		}
		
		let deleteAction = UIAlertAction(title: NSLocalizedString(LocalizeKeys.deleteAction, comment: ""), style: .destructive) { _ in
			self.imageView.image = nil
		}
		
		picker.delegate = self
		alert.addAction(cameraAction)
		alert.addAction(gallaryAction)
		alert.addAction(deleteAction)
		present(alert, animated: true, completion: nil)
	}
	
	
	//MARK: - Private functions
	
	private func openCamera() {
		if (UIImagePickerController .isSourceTypeAvailable(.camera)){
			picker.sourceType = .camera
			present(picker, animated: true, completion: nil)
		} else {
			print("No access to the camera")
		}
	}
	private func openGallary() {
		picker.sourceType = .photoLibrary
		present(picker, animated: true, completion: nil)
	}
	
	private func setupElements() {
		
		let headerView = UIView()
//		headerView.backgroundColor = (traitCollection.userInterfaceStyle == .dark) ? .darkGray.withAlphaComponent(0.4) :  UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1)
		headerView.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		headerView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(headerView)
		headerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		headerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		headerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		headerView.heightAnchor.constraint(equalToConstant: 96).isActive = true
		
		let profileLabel = ProfileLabel(text: NSLocalizedString(LocalizeKeys.profileLabel, comment: ""), font: UIFont.boldSystemFont(ofSize: 26))
		profileLabel.textColor = NavigationBarAppearance.elementsColor.uiColor()
		headerView.addSubview(profileLabel)
		
		closeButton = ProfileButton(title: NSLocalizedString(LocalizeKeys.closeButtonTitle, comment: ""), fontSize: 17)
		closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
		headerView.addSubview(closeButton)
		
		profileLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16).isActive = true
		profileLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
		closeButton.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -16).isActive = true
		closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
		
		imageView = UserImageView(labelTitle: user.initials, labelfontSize: 120)
		imageView.layer.cornerRadius = 120
		view.addSubview(imageView)
		imageView.widthAnchor.constraint(equalToConstant: 240).isActive = true
		imageView.heightAnchor.constraint(equalToConstant: 240).isActive = true
		imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		imageView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 7).isActive = true
		
		let nameLabel = ProfileLabel(text: user.fullName, font: UIFont.boldSystemFont(ofSize: 24))
		nameLabel.textColor = NavigationBarAppearance.elementsColor.uiColor()
		view.addSubview(nameLabel)
		nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 32).isActive = true
		
		let infoLabel = ProfileLabel(text: user.info, font: UIFont.systemFont(ofSize: 16))
		infoLabel.textColor = NavigationBarAppearance.elementsColor.uiColor()
		infoLabel.numberOfLines = 0
		infoLabel.lineBreakMode = .byWordWrapping
		view.addSubview(infoLabel)
		infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		infoLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 32).isActive = true
		
		saveButton = ProfileButton(title: NSLocalizedString(LocalizeKeys.saveButtonTitle, comment: ""), fontSize: 19)
		saveButton.layer.cornerRadius = 14
//		saveButton.backgroundColor = (traitCollection.userInterfaceStyle == .dark) ? .darkGray.withAlphaComponent(0.4) : UIColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 1)
		saveButton.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		saveButton.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
		view.addSubview(saveButton)
		saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		saveButton.widthAnchor.constraint(equalToConstant: 263).isActive = true
		saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
		saveButton.topAnchor.constraint(greaterThanOrEqualTo: infoLabel.bottomAnchor).isActive = true
		saveButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
		
		editButton = ProfileButton(title: NSLocalizedString(LocalizeKeys.editButtonTitle, comment: ""), fontSize: 16)
		editButton.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
		view.addSubview(editButton)
		editButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
		editButton.heightAnchor.constraint(equalToConstant: 40).isActive =  true
		editButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -22).isActive = true
		editButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
		
	}
}

extension ProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
	
	//MARK:UIImagePickerControllerDelegate
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		picker.dismiss(animated: true, completion: nil)
		imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		print("picker cancel.")
	}
}
