//
//  ProfileViewController.swift
//  Chat
//
//  Created by Сергей on 24.09.2021.
//

import UIKit

class ProfileViewController: UIViewController {
	
	var closeButton: UIButton!
	var imageView: UIImageView!
	var user = Owner()
	var saveButton: UIButton!
	var editButton: UIButton!
	
	private var picker = UIImagePickerController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = (traitCollection.userInterfaceStyle == .dark) ? UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1) : .white
		
		// До вызова setupElements() невозможно узнать saveButton.frame, так как кнопка еще не проинициализирована
		setupElements()
		print(saveButton.frame) // (0.0, 0.0, 0.0, 0.0)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		/*
		 Во viewDidLoad() происходит инициализация, настройка и установка значений constraints для каждого UI элемента. Frame рассчитывается позднее, когда будут известны constraints всех UI элементов.
		 */
		print(saveButton.frame) // (56.0, 696.0, 263.0, 32.0)
	}
	
	//MARK: - Init
	
	init() {
		super.init(nibName: nil, bundle: nil)
		// Невозможно узнать saveButton.frame, так как кнопка еще не проинициализирована
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	//MARK: - Actions
	
	@objc func closeButtonAction(_ sender: UIButton) {
		self.navigationController?.popViewController(animated: true)
		self.dismiss(animated: true, completion: nil)
	}
	
	@objc func saveButtonAction(_ sender: UIButton) {
		print("Save button tapped")
	}
	
	@objc func editButtonAction(_ sender: UIButton) {
		
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let cameraAction = UIAlertAction(title: NSLocalizedString("cameraAction", comment: ""), style: .default) { _ in
			self.openCamera()
		}
		
		let gallaryAction = UIAlertAction(title: NSLocalizedString("gallaryAction", comment: ""), style: .default) { _ in
			self.openGallary()
		}
		
		let deleteAction = UIAlertAction(title: NSLocalizedString("deleteAction", comment: ""), style: .destructive) { _ in
			self.imageView.image = nil
		}
		
		picker.delegate = self
		alert.addAction(cameraAction)
		alert.addAction(gallaryAction)
		alert.addAction(deleteAction)
		self.present(alert, animated: true, completion: nil)
	}
	
	
	//MARK: - Private functions
	
	private func openCamera() {
		if (UIImagePickerController .isSourceTypeAvailable(.camera)){
			picker.sourceType = .camera
			self.present(picker, animated: true, completion: nil)
		} else {
			print("No access to the camera")
		}
	}
	private func openGallary() {
		picker.sourceType = .photoLibrary
		self.present(picker, animated: true, completion: nil)
	}
	
	private func setupElements() {
		
		let headerView = UIView()
		headerView.backgroundColor = (traitCollection.userInterfaceStyle == .dark) ? .darkGray.withAlphaComponent(0.4) :  UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1)
		headerView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(headerView)
		headerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
		headerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
		headerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
		headerView.heightAnchor.constraint(equalToConstant: 96).isActive = true
		
		let profileLabel = ProfileLabel(text: NSLocalizedString("profileLabel", comment: ""), font: UIFont.boldSystemFont(ofSize: 26))
		headerView.addSubview(profileLabel)
		
		closeButton = ProfileButton(title: NSLocalizedString("closeButtonTitle", comment: ""), fontSize: 17)
		closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
		headerView.addSubview(closeButton)
		
		profileLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16).isActive = true
		profileLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
		closeButton.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -16).isActive = true
		closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
		
		imageView = UserImageView(labelTitle: user.initials, labelfontSize: 120)
		imageView.layer.cornerRadius = 120
		self.view.addSubview(imageView)
		imageView.widthAnchor.constraint(equalToConstant: 240).isActive = true
		imageView.heightAnchor.constraint(equalToConstant: 240).isActive = true
		imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
		imageView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 7).isActive = true
		
		let nameLabel = ProfileLabel(text: user.fullName, font: UIFont.boldSystemFont(ofSize: 24))
		self.view.addSubview(nameLabel)
		nameLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
		nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 32).isActive = true
		
		let infoLabel = ProfileLabel(text: user.info, font: UIFont.systemFont(ofSize: 16))
		infoLabel.numberOfLines = 0
		infoLabel.lineBreakMode = .byWordWrapping
		self.view.addSubview(infoLabel)
		infoLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
		infoLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 32).isActive = true
		
		saveButton = ProfileButton(title: NSLocalizedString("saveButtonTitle", comment: ""), fontSize: 19)
		saveButton.layer.cornerRadius = 14
		saveButton.backgroundColor = (traitCollection.userInterfaceStyle == .dark) ? .darkGray.withAlphaComponent(0.4) : UIColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 1)
		saveButton.addTarget(self, action: #selector(saveButtonAction), for: .touchUpInside)
		self.view.addSubview(saveButton)
		saveButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
		saveButton.widthAnchor.constraint(equalToConstant: 263).isActive = true
		saveButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30).isActive = true
		saveButton.topAnchor.constraint(greaterThanOrEqualTo: infoLabel.bottomAnchor).isActive = true
		saveButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
		
		editButton = ProfileButton(title: NSLocalizedString("editButtonTitle", comment: ""), fontSize: 16)
		editButton.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
		self.view.addSubview(editButton)
		editButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
		editButton.heightAnchor.constraint(equalToConstant: 40).isActive =  true
		editButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -22).isActive = true
		editButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -25).isActive = true
		
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
