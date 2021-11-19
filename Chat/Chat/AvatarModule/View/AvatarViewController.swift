//
//  AvatarViewController.swift
//  Chat
//
//  Created by Сергей on 19.11.2021.
//

import UIKit

class AvatarViewController: UIViewController {
	
	internal enum Constants {
		static let cellReuseIdentifier = "AvatarCell"
		static let cellOffset = 5.0
		static let buttonFontSize = 30.0
	}
	
	private enum LocalizeKeys {
		static let cancelButtonTitle = "cancelButtonTitle"
	}
	
	var presenter: AvatarPresenterProtocol?
	
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

extension AvatarViewController: AvatarViewProtocol {
	func cancellButtonTapped() {
		dismiss(animated: true, completion: nil)
	}
}

extension AvatarViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 102
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellReuseIdentifier, for: indexPath)
		
		var image: UIImage?
		if #available(iOS 13.0, *) {
			image = UIImage(systemName: "person")
			
		} else {
			image = UIImage(named: "placeholderImage")
		}
		let imageView = UIImageView(frame: cell.bounds)
		imageView.image = image
		imageView.tintColor = .lightGray.withAlphaComponent(0.7)
		cell.backgroundView = imageView
		cell.backgroundColor = TableViewCellAppearance.backgroundColor.uiColor()
		return cell
	}

}

extension AvatarViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let size = collectionView.bounds.width / 3 - (Constants.cellOffset * 2)
		return CGSize(width: size, height: size)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: Constants.cellOffset, left: Constants.cellOffset, bottom: Constants.cellOffset, right: Constants.cellOffset)
	}
}
