//
//  ImagePickerViewController.swift
//  Chat
//
//  Created by Сергей on 19.11.2021.
//

import UIKit

class ImagePickerViewController: UIViewController {
	
	internal enum Constants {
		static let cellReuseIdentifier = "AvatarCell"
		static let cellOffset = 5.0
		static let buttonFontSize = 30.0
	}
	
	private enum LocalizeKeys {
		static let cancelButtonTitle = "cancelButtonTitle"
	}
	
	var presenter: ImagePickerPresenterProtocol?
	
	private lazy var headerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		return view
	}()
	
	private lazy var cancelButton: UIButton = {
		let button = ProfileButton(title: NSLocalizedString(LocalizeKeys.cancelButtonTitle, comment: ""), fontSize: Constants.buttonFontSize)
		button.addTarget(self, action: #selector(cancelButtonAction(_:)), for: .touchUpInside)
		return button
	}()
	
	private lazy var activityIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView()
		indicator.isHidden = false
		indicator.startAnimating()
		indicator.color = NavigationBarAppearance.elementsColor.uiColor().withAlphaComponent(0.8)
		indicator.translatesAutoresizingMaskIntoConstraints = false
		return indicator
	}()
	
	private lazy var collectionView: UICollectionView = {
		let flowLayout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.backgroundColor = TableViewAppearance.backgroundColor.uiColor()
		collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: Constants.cellReuseIdentifier)
		collectionView.dataSource = self
		collectionView.delegate = self
		return collectionView
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setup()
    }
	
	// MARK: - Actions
	@objc func cancelButtonAction(_ sender: UIButton) {
		presenter?.cancellButtonTapped()
	}
	
	// MARK: - Private functions
	private func setup() {
		view.backgroundColor = TableViewCellAppearance.backgroundColor.uiColor()
	
		headerView.addSubview(cancelButton)
		setupCancelButtonConstraints()
		
		view.addSubview(headerView)
		setupHeaderViewConstraints()
		
		view.addSubview(collectionView)
		setupCollectionViewConstraints()
		
		collectionView.addSubview(activityIndicator)
		activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		
	}
	
	private func setupHeaderViewConstraints() {
		headerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		headerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		headerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		headerView.heightAnchor.constraint(equalToConstant: 44).isActive = true
	}
	
	private func setupCancelButtonConstraints() {
		cancelButton.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -10).isActive = true
		cancelButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -4).isActive = true
		cancelButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
		cancelButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
	}
	
	private func setupCollectionViewConstraints() {
		collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
		collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
	}
}

extension ImagePickerViewController: ImagePickerViewProtocol {

	func loadImagesListSucsess() {
		collectionView.reloadData()
		activityIndicator.stopAnimating()
		activityIndicator.isHidden = true
	}
	
	func cancellButtonTapped() {
		dismiss(animated: true, completion: nil)
	}
	
}

extension ImagePickerViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return presenter?.imagesList.count ?? 0
//		return 102
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellReuseIdentifier, for: indexPath)
		
		var image: UIImage?
		
//		let imageView = UIImageView(frame: cell.bounds)
//		imageView.tintColor = .lightGray.withAlphaComponent(0.7)
//		cell.contentView.addSubview(imageView)
//		cell.contentView = imageView
//		cell.backgroundView = imageView
		
		if #available(iOS 13.0, *) {
			image = UIImage(systemName: "person")

		} else {
			image = UIImage(named: "placeholderImage")
		}
		let backgroundView = UIImageView(frame: cell.bounds)
		backgroundView.image = image
		backgroundView.tintColor = .lightGray.withAlphaComponent(0.7)
		presenter?.setImageForCellImageView(backgroundView, forIndexPath: indexPath)
		cell.backgroundView = backgroundView
		cell.backgroundColor = TableViewCellAppearance.backgroundColor.uiColor()
//		cell.isUserInteractionEnabled = false
		return cell
	}

}

extension ImagePickerViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let cell = collectionView.cellForItem(at: indexPath) else { return }
		presenter?.didSelectCell(cell)
	}
}

extension ImagePickerViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let size = collectionView.bounds.width / 3 - (Constants.cellOffset * 2)
		return CGSize(width: size, height: size)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: Constants.cellOffset, left: Constants.cellOffset, bottom: Constants.cellOffset, right: Constants.cellOffset)
	}
}
