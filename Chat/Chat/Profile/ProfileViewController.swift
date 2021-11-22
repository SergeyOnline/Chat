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
		static let cancelAction = "cancelAction"
		static let deleteAction = "deleteAction"
		static let downloadAction = "downloadAction"
		static let profileLabel = "profileLabel"
		static let closeButtonTitle = "closeButtonTitle"
		static let editButtonTitle = "editButtonTitle"
		static let editImageButtonTitle = "editImageButtonTitle"
		static let cancelButtonTitle = "cancelButtonTitle"
		static let nameTextFieldPlaceholder = "nameTextFieldPlaceholder"
		static let alertOkActionTitle = "alertOkActionTitle"
		static let alertRepeatSaveAction = "alertRepeatSaveAction"
		static let successAlertTitle = "successAlertTitle"
		static let failureAlertTitle = "failureAlertTitle"
		static let failureAlertMessage = "failureAlertMessage"
		static let saveButtonTitle = "saveButtonTitle"
	}
	private enum Constants {
		static let keyboardNotificatoinKey = "UIKeyboardFrameEndUserInfoKey"
	}
	internal enum SaveButtonStatus {
		case enable
		case disable
	}
	
	// MARK: - Model
	var owner = Owner()
	
	// MARK: - UI
	private var imageView: UserImageView
	internal var infoTextView: UITextView = {
		let textView = UITextView()
		textView.isScrollEnabled = false
		textView.textContainer.maximumNumberOfLines = 2
		textView.font = UIFont.systemFont(ofSize: 16)
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.isUserInteractionEnabled = false
		return textView
	}()
	lazy var editButton: UIButton = {
		let button = ProfileButton(title: NSLocalizedString(LocalizeKeys.editButtonTitle, comment: ""), fontSize: 19)
		button.layer.cornerRadius = 14
		button.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
		return button
	}()
	private lazy var editImageButton: UIButton = {
		let button = ProfileButton(title: NSLocalizedString(LocalizeKeys.editImageButtonTitle, comment: ""), fontSize: 16)
		button.setTitleColor(.systemBlue, for: .normal)
		button.setTitleColor(.systemGray, for: .disabled)
		button.addTarget(self, action: #selector(editImageButtonAction), for: .touchUpInside)
		return button
	}()
	private lazy var cancelButton: UIButton = {
		let button = ProfileButton(title: NSLocalizedString(LocalizeKeys.cancelButtonTitle, comment: ""), fontSize: 16)
		button.layer.cornerRadius = 14
		button.setTitleColor(.systemBlue, for: .normal)
		button.setTitleColor(.systemGray, for: .disabled)
		button.addTarget(self, action: #selector(cancelButtonAction(_:)), for: .touchUpInside)
		button.isHidden = true
		return button
	}()
	private lazy var saveButton: UIButton = {
		let button = ProfileButton(title: NSLocalizedString(LocalizeKeys.saveButtonTitle, comment: ""), fontSize: 14)
		button.layer.cornerRadius = 14
		button.setTitleColor(.systemBlue, for: .normal)
		button.setTitleColor(.systemGray, for: .disabled)
		button.addTarget(self, action: #selector(saveButtonAction(_:)), for: .touchUpInside)
		button.isHidden = true
		return button
	}()
	private lazy var nameTextField: UITextField = {
		let textField = UITextField()
		textField.font = UIFont.boldSystemFont(ofSize: 20)
		textField.translatesAutoresizingMaskIntoConstraints = false
		let placeholder = NSLocalizedString(LocalizeKeys.nameTextFieldPlaceholder, comment: "")
		textField.attributedPlaceholder = NSAttributedString(string: placeholder,
															 attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray])
		textField.isEnabled = false
		textField.addTarget(self, action: #selector(nameTextFieldEditing(_:)), for: .editingChanged)
		return textField
	}()
	private var profileLabel = ProfileLabel(text: NSLocalizedString(LocalizeKeys.profileLabel, comment: ""), font: UIFont.boldSystemFont(ofSize: 26))
	
	private var headerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	private var activityIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView()
		indicator.translatesAutoresizingMaskIntoConstraints = false
		return indicator
	}()
	private let userProfileHandlerGCD = GCDUserProfileInfoHandler()
	private var picker = UIImagePickerController()
	private var isKeyboardHidden = true
	var completion: (() -> Void) = {}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateTheme()
	}
	
	// MARK: - Init
	init() {
		imageView = UserImageView(labelTitle: owner.initials, labelfontSize: 120)
		infoTextView.text = owner.info
		super.init(nibName: nil, bundle: nil)
	}
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Actions
	@objc func editButtonAction(_ sender: UIButton) {
		editImageButton.isHidden = true
		tabBarController?.tabBar.isHidden = true
		showSaveButtons()
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
			self.userProfileHandlerGCD.saveOwnerImage(image: nil) { _ in
				DispatchQueue.main.async {
					self.completion()
				}
			}
		}
		let downloadAction = UIAlertAction(title: NSLocalizedString(LocalizeKeys.downloadAction, comment: ""), style: .default) { _ in
			let avatarVC = ModuleAssembly.createImagePickerModule()
			if let avatarController = avatarVC as? ImagePickerViewController {
				avatarController.presenter?.completion = { image, _ in
					self.imageView.image = image
					self.imageView.contentMode = UIImageView.ContentMode.scaleAspectFill
					self.userProfileHandlerGCD.saveOwnerImage(image: image) { _ in
						DispatchQueue.main.async {
							self.completion()
						}
					}
				}
			}
			self.present(avatarVC, animated: true, completion: nil)
		}
		picker.delegate = self
		alert.addAction(cameraAction)
		alert.addAction(gallaryAction)
		alert.addAction(downloadAction)
		alert.addAction(deleteAction)
		alert.setThemeOptions(viewBackground: TableViewCellAppearance.backgroundColor.uiColor(),
							   titleColor: NavigationBarAppearance.elementsColor.uiColor(),
							   buttonsBackground: NavigationBarAppearance.backgroundColor.uiColor(),
							   tintColor: NavigationBarAppearance.elementsColor.uiColor())
		present(alert, animated: true) {
			alert.view.superview?.subviews.first?.isUserInteractionEnabled = true
			alert.view.superview?.subviews.first?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertTapGestureHandler(_:))))
		}
	}

	@objc func alertTapGestureHandler(_ sender: UITapGestureRecognizer) {
		dismiss(animated: true, completion: nil)
	}
	
	@objc func cancelButtonAction(_ sender: UIButton) {
		hideSaveButtons()
		textFieldsResignFirstResponder()
		userProfileHandlerGCD.loadOwnerInfo { [weak self] in
			switch $0 {
			case .success(let owner):
				self?.owner = owner
				self?.infoTextView.text = owner.info
				self?.nameTextField.text = owner.fullName
				self?.imageView.setInitials(initials: owner.initials)
			case .failure:
				self?.owner = Owner()
			}
		}
		editImageButton.isHidden = false
	}
	@objc func saveButtonAction(_ sender: UIButton) {
		textFieldsResignFirstResponder()
		activityIndicator.startAnimating()
		changeSaveButtonsStatusTo(.disable)
		cancelButton.isEnabled = false
		owner.fullName = nameTextField.text ?? ""
		owner.info = infoTextView.text
		userProfileHandlerGCD.saveOwnerInfo(owner: owner) { [weak self] error in
			DispatchQueue.main.async {
				self?.setupAfterSaveOperation(sender: sender, error: error)
			}
		}
	}
	@objc func nameTextFieldEditing(_ sender: UITextField) {
		guard let text = sender.text else { return }
		if text.isEmpty {
			changeSaveButtonsStatusTo(.disable)
		} else {
			changeSaveButtonsStatusTo(.enable)
		}
		if (sender.text?.count ?? 0) > 28 || (text.numberOfWords == 2 && text.last == " ") {
			sender.text?.removeLast()
		}
	}
	@objc func keyboardWillShow(_ sender: NSNotification) {
		if isKeyboardHidden {
			tabBarController?.tabBar.isHidden = true
			isKeyboardHidden = false
			guard let info = sender.userInfo else { return }
			guard let rect = info[Constants.keyboardNotificatoinKey] as? CGRect else { return }
			let height = rect.height
			let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - height)
			view.frame = frame
			imageView.isHidden = true
			for constraint in imageView.constraints where constraint.firstAttribute == .height {
				constraint.constant = 1
			}
			editImageButton.isHidden = true
		}
	}
	@objc func keyboardWillHide(_ sender: NSNotification) {
		if !isKeyboardHidden {
			tabBarController?.tabBar.isHidden = false
			isKeyboardHidden = true
			guard let info = sender.userInfo else { return }
			guard let rect = info[Constants.keyboardNotificatoinKey] as? CGRect else { return }
			let height = rect.height
			let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + height)
			self.view.frame = frame
			imageView.isHidden = false
			for constraint in imageView.constraints where constraint.firstAttribute == .height {
				constraint.constant = 240
			}
			editImageButton.isHidden = false
		}
	}
	
	func updateTheme() {
		view.backgroundColor = TableViewCellAppearance.backgroundColor.uiColor()
		infoTextView.textColor = NavigationBarAppearance.elementsColor.uiColor()
		infoTextView.backgroundColor = TableViewCellAppearance.backgroundColor.uiColor()
		editButton.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		cancelButton.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		saveButton.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		nameTextField.textColor = NavigationBarAppearance.elementsColor.uiColor()
		headerView.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		profileLabel.textColor = NavigationBarAppearance.elementsColor.uiColor()
	}
	
	// MARK: - Private functions
	private func openCamera() {
		if UIImagePickerController .isSourceTypeAvailable(.camera) {
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
		imageView.contentMode = UIImageView.ContentMode.scaleAspectFill
		setupHeaderViewConstraints()
		userProfileHandlerGCD.loadOwnerInfo { [weak self] in
			switch $0 {
			case .success(let owner):
				self?.owner = owner
				self?.infoTextView.text = owner.info
				self?.nameTextField.text = owner.fullName
				self?.imageView.setInitials(initials: owner.initials)
			case .failure:
				self?.owner = Owner()
			}
		}
		userProfileHandlerGCD.loadOwnerImage { [weak self] in
			switch $0 {
			case .success(let image):
				self?.imageView.image = image
			case .failure:
				break
			}
		}
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
		
		headerView.addSubview(profileLabel)
		profileLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16).isActive = true
		profileLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: 20).isActive = true
		
		imageView.layer.cornerRadius = 120
		if let imageData = UserDefaults.standard.data(forKey: UserDefaultsKeys.userImage) {
			imageView.image = UIImage(data: imageData)
		}
		view.addSubview(imageView)
		setupImageViewConstraints()
		
		nameTextField.text = owner.fullName
		nameTextField.delegate = self
		view.addSubview(nameTextField)
		setupNameTextFieldConstraints()
		
		infoTextView.delegate = self
		view.addSubview(infoTextView)
		setupInfoTextViewConstraints()
		
		view.addSubview(activityIndicator)
		activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		activityIndicator.centerYAnchor.constraint(equalTo: infoTextView.centerYAnchor, constant: 50).isActive = true
		
		view.addSubview(editButton)
		setupEditButtonConstraints()
		
		view.addSubview(cancelButton)
		setupCancelButtonConctraints()
		
		view.addSubview(saveButton)
		setupSaveButtonConctraints()
		
		view.addSubview(editImageButton)
		setupEditImageButtonConstraints()
	}
	private func showSuccessAlert() {
		let alertController = UIAlertController(title: NSLocalizedString(LocalizeKeys.successAlertTitle, comment: ""),
												message: "", preferredStyle: .alert)
		let okAction = UIAlertAction(title: NSLocalizedString(LocalizeKeys.alertOkActionTitle, comment: ""), style: .default, handler: nil)
		alertController.addAction(okAction)
		alertController.setThemeOptions(viewBackground: TableViewCellAppearance.backgroundColor.uiColor(),
										 titleColor: NavigationBarAppearance.elementsColor.uiColor(),
										 buttonsBackground: NavigationBarAppearance.backgroundColor.uiColor(),
										 tintColor: NavigationBarAppearance.elementsColor.uiColor())
		self.present(alertController, animated: true, completion: nil)
	}
	private func showFailureAlert(sender: UIButton) {
		let alertController = UIAlertController(title: NSLocalizedString(LocalizeKeys.failureAlertTitle, comment: ""),
												message: NSLocalizedString(LocalizeKeys.failureAlertMessage, comment: ""), preferredStyle: .alert)
		let okAction = UIAlertAction(title: NSLocalizedString(LocalizeKeys.alertOkActionTitle, comment: ""), style: .default, handler: nil)
		let repeatSaveAction = UIAlertAction(title: NSLocalizedString(LocalizeKeys.alertRepeatSaveAction, comment: ""), style: .default) { _ in
			self.saveButtonAction(sender)
		}
		alertController.addAction(okAction)
		alertController.addAction(repeatSaveAction)
		alertController.setThemeOptions(viewBackground: TableViewCellAppearance.backgroundColor.uiColor(),
										 titleColor: NavigationBarAppearance.elementsColor.uiColor(),
										 buttonsBackground: NavigationBarAppearance.backgroundColor.uiColor(),
										 tintColor: NavigationBarAppearance.elementsColor.uiColor())
		self.present(alertController, animated: true, completion: nil)
	}
	internal func changeSaveButtonsStatusTo(_ status: SaveButtonStatus) {
		switch status {
		case .enable: saveButton.isEnabled = true
		case .disable: saveButton.isEnabled = false
		}
	}
	private func hideSaveButtons() {
		saveButton.isHidden = true
		cancelButton.isHidden = true
		nameTextField.isEnabled = false
		infoTextView.isUserInteractionEnabled = false
		editButton.isHidden = false
		tabBarController?.tabBar.isHidden = false
	}
	private func showSaveButtons() {
		editButton.isHidden = true
		cancelButton.isHidden = false
		saveButton.isHidden = false
		saveButton.isEnabled = false
		infoTextView.isUserInteractionEnabled = true
		nameTextField.isEnabled = true
		nameTextField.becomeFirstResponder()
	}
	private func setupInfoTextViewConstraints() {
		infoTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		infoTextView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 5).isActive = true
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
		editButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
		editButton.topAnchor.constraint(greaterThanOrEqualTo: infoTextView.bottomAnchor).isActive = true
		editButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
	}
	private func setupCancelButtonConctraints() {
		cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
		cancelButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
		cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -72).isActive = true
		cancelButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
	}
	private func setupSaveButtonConctraints() {
		saveButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
		saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
		saveButton.topAnchor.constraint(greaterThanOrEqualTo: cancelButton.bottomAnchor, constant: 5).isActive = true
		saveButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
	}
	private func setupEditImageButtonConstraints() {
		editImageButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
		editImageButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
		editImageButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -22).isActive = true
		editImageButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
	}
	private func setupNameTextFieldConstraints() {
		nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		nameTextField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10).isActive = true
		nameTextField.heightAnchor.constraint(equalToConstant: 36).isActive = true
	}
	private func setupAfterSaveOperation(sender: UIButton, error: Error?) {
		if error != nil {
			self.showFailureAlert(sender: sender)
		} else {
			self.imageView.setInitials(initials: self.owner.initials)
			self.showSuccessAlert()
		}
		self.activityIndicator.stopAnimating()
		self.changeSaveButtonsStatusTo(.enable)
		self.cancelButton.isEnabled = true
		self.hideSaveButtons()
		self.editImageButton.isHidden = false
		self.view.setNeedsLayout()
		completion()
	}
	private func textFieldsResignFirstResponder() {
		if nameTextField.isFirstResponder {
			nameTextField.resignFirstResponder()
		}
		if infoTextView.isFirstResponder {
			infoTextView.resignFirstResponder()
		}
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}

extension ProfileViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
	// MARK: - Image Picker Controller Delegate
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
