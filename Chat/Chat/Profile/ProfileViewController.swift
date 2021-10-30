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
	
	//MARK: - Model
	var user = Owner()
	
	//MARK: - UI
	private var closeButton: UIButton = {
		let button = ProfileButton(title: NSLocalizedString(LocalizeKeys.closeButtonTitle, comment: ""), fontSize: 17)
		button.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
		return button
	}()
	
	private var imageView: UIImageView
	private var infoLabel: ProfileLabel
	
	var saveButton: UIButton = {
		let button = ProfileButton(title: NSLocalizedString(LocalizeKeys.saveButtonTitle, comment: ""), fontSize: 19)
		button.layer.cornerRadius = 14
		button.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		button.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
		return button
	}()
	
	private var editButton: UIButton = {
		let button = ProfileButton(title: NSLocalizedString(LocalizeKeys.editButtonTitle, comment: ""), fontSize: 16)
		button.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
		return button
	}()
	
	private var headerView: UIView = {
		let view = UIView()
		view.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	var completion: (()-> Void)!
	
	private var picker = UIImagePickerController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = TableViewCellAppearance.backgroundColor.uiColor()
		setup()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	//MARK: - Init
	
	init() {
		imageView = UserImageView(labelTitle: user.initials, labelfontSize: 120)
		infoLabel = ProfileLabel(text: user.info, font: UIFont.systemFont(ofSize: 16))
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
			UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.userImage)
			self.completion()
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
	
	private func setup() {
		
		view.addSubview(headerView)
		setupHeaderViewConstraints()
		
		let profileLabel = ProfileLabel(text: NSLocalizedString(LocalizeKeys.profileLabel, comment: ""), font: UIFont.boldSystemFont(ofSize: 26))
		profileLabel.textColor = NavigationBarAppearance.elementsColor.uiColor()
		headerView.addSubview(profileLabel)
		headerView.addSubview(closeButton)
		
		profileLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16).isActive = true
		profileLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
		closeButton.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -16).isActive = true
		closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
		
		imageView.layer.cornerRadius = 120
		if let imageData = UserDefaults.standard.data(forKey: UserDefaultsKeys.userImage) {
			imageView.image = UIImage(data: imageData)
		}
		view.addSubview(imageView)
		setupImageViewConstraints()
		
		let nameLabel = ProfileLabel(text: user.fullName, font: UIFont.boldSystemFont(ofSize: 24))
		nameLabel.textColor = NavigationBarAppearance.elementsColor.uiColor()
		view.addSubview(nameLabel)
		nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 32).isActive = true
		
		setupInfoLabel()
		view.addSubview(infoLabel)
		infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		infoLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 32).isActive = true
		
		view.addSubview(saveButton)
		setupSaveButtonConstraints()
		
		view.addSubview(editButton)
		setupEditButtonConstraints()
		
	}
	
	private func setupInfoLabel() {
		infoLabel.textColor = NavigationBarAppearance.elementsColor.uiColor()
		infoLabel.numberOfLines = 0
		infoLabel.lineBreakMode = .byWordWrapping
	}
	
	private func setupHeaderViewConstraints() {
		headerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		headerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		headerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		headerView.heightAnchor.constraint(equalToConstant: 96).isActive = true
	}
	
	private func setupImageViewConstraints() {
		imageView.widthAnchor.constraint(equalToConstant: 240).isActive = true
		imageView.heightAnchor.constraint(equalToConstant: 240).isActive = true
		imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		imageView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 7).isActive = true
	}
	
	private func setupSaveButtonConstraints() {
		saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		saveButton.widthAnchor.constraint(equalToConstant: 263).isActive = true
		saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
		saveButton.topAnchor.constraint(greaterThanOrEqualTo: infoLabel.bottomAnchor).isActive = true
		saveButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
	}
	
	private func setupEditButtonConstraints() {
		editButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
		editButton.heightAnchor.constraint(equalToConstant: 40).isActive =  true
		editButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -22).isActive = true
		editButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
	}
}

extension ProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
	
	//MARK: - Image Picker Controller Delegate
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		picker.dismiss(animated: true, completion: nil)
		imageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
		
		guard let image = imageView.image else { return }
		let imageData = image.jpegData(compressionQuality: 0.3)
		UserDefaults.standard.set(imageData, forKey: UserDefaultsKeys.userImage)
		completion()
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}
