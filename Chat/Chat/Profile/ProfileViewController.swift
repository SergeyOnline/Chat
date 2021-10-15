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
		static let editButtonTitle = "editButtonTitle"
		static let editImageButtonTitle = "editImageButtonTitle"
		static let cancelButtonTitle = "cancelButtonTitle"
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
	
	var editButton: UIButton = {
		let button = ProfileButton(title: NSLocalizedString(LocalizeKeys.editButtonTitle, comment: ""), fontSize: 19)
		button.layer.cornerRadius = 14
		button.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		button.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
		return button
	}()
	
	private var editImageButton: UIButton = {
		let button = ProfileButton(title: NSLocalizedString(LocalizeKeys.editImageButtonTitle, comment: ""), fontSize: 16)
		button.addTarget(self, action: #selector(editImageButtonAction), for: .touchUpInside)
		return button
	}()
	
	private var cancelButton: UIButton = {
		let button = ProfileButton(title: NSLocalizedString(LocalizeKeys.cancelButtonTitle, comment: ""), fontSize: 16)
		button.layer.cornerRadius = 14
		button.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		button.addTarget(self, action: #selector(cancelButtonAction(_:)), for: .touchUpInside)
		button.isHidden = true
		return button
	}()
	
	private var saveGCDButton: UIButton = {
		let button = ProfileButton(title: "Save GCD", fontSize: 14)
		button.layer.cornerRadius = 14
		button.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		
		button.isHidden = true
		return button
	}()
	
	private var saveOperationsButton: UIButton = {
		let button = ProfileButton(title: "Save Operations", fontSize: 14)
		button.layer.cornerRadius = 14
		button.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		
		button.isHidden = true
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
	
	@objc func editButtonAction(_ sender: UIButton) {
		sender.isHidden = true
		cancelButton.isHidden = false
		saveGCDButton.isHidden = false
		saveOperationsButton.isHidden = false
		print("Edit button tapped")
	}
	
	@objc func editImageButtonAction(_ sender: UIButton) {
		
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
	
	@objc func cancelButtonAction(_ sender: UIButton) {
		sender.isHidden = true
		editButton.isHidden = false
		saveGCDButton.isHidden = true
		saveOperationsButton.isHidden = true
		print("Cancel button tapped")
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
		
		view.addSubview(editButton)
		setupEditButtonConstraints()
		
		view.addSubview(cancelButton)
		setupCancelButtonConctraints()
		
		view.addSubview(saveGCDButton)
		setupSaveGCDButtonConctraints()
		
		view.addSubview(saveOperationsButton)
		setupSaveOperationsButtonConctraints()
		
		view.addSubview(editImageButton)
		setupEditImageButtonConstraints()
		
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
	
	private func setupEditButtonConstraints() {
		editButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		editButton.widthAnchor.constraint(equalToConstant: 263).isActive = true
		editButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
		editButton.topAnchor.constraint(greaterThanOrEqualTo: infoLabel.bottomAnchor).isActive = true
		editButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
	}
	
	private func setupCancelButtonConctraints() {
		cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
		cancelButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
		cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80).isActive = true
		cancelButton.topAnchor.constraint(greaterThanOrEqualTo: infoLabel.bottomAnchor).isActive = true
		cancelButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
	}
	
	private func setupSaveGCDButtonConctraints() {
		saveGCDButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
		saveGCDButton.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -5).isActive = true
		saveGCDButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
		saveGCDButton.topAnchor.constraint(greaterThanOrEqualTo: infoLabel.bottomAnchor).isActive = true
		saveGCDButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
	}
	
	private func setupSaveOperationsButtonConctraints() {
		saveOperationsButton.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: 5).isActive = true
		saveOperationsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
		saveOperationsButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
//		saveOperationsButton.topAnchor.constraint(greaterThanOrEqualTo: infoLabel.bottomAnchor).isActive = true
		saveOperationsButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
	}
	
	private func setupEditImageButtonConstraints() {
		editImageButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
		editImageButton.heightAnchor.constraint(equalToConstant: 40).isActive =  true
		editImageButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -22).isActive = true
		editImageButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
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
