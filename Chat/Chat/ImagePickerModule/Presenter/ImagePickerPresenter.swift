//
//  AvatarPresenter.swift
//  Chat
//
//  Created by Сергей on 19.11.2021.
//

import Foundation
import UIKit

internal struct ImageAndLink {
	let image: UIImage
	let link: String
}

protocol ImagePickerViewProtocol: AnyObject {
	func cancellButtonTapped()
	func loadImagesListSucsess()
}

protocol ImagePickerPresenterProtocol: AnyObject {
	init(view: ImagePickerViewProtocol, networkService: NetworkServiceProtocol)
	func cancellButtonTapped()
	func didSelectCell(_ cell: UICollectionViewCell)
	func setImageForCellImageView(_ imageView: UIImageView, forIndexPath indexPath: IndexPath)
	var imagesList: [ImageInfo] { get }
	var completion: ((ImageAndLink) -> Void) { get set }
	
}

final class ImagePickerPresenter: ImagePickerPresenterProtocol {
	
	weak var view: ImagePickerViewProtocol?
	var imagesList: [ImageInfo] = []
	let networkService: NetworkServiceProtocol
	var completion: ((ImageAndLink) -> Void) = {_ in }
	
	required init(view: ImagePickerViewProtocol, networkService: NetworkServiceProtocol) {
		self.view = view
		self.networkService = networkService
		getImageList()
	}
	
	func cancellButtonTapped() {
		view?.cancellButtonTapped()
	}
	
	private func getImageList() {
		networkService.getImagesList { [weak self] result in
			guard let self = self else { return }
			DispatchQueue.main.async {
				switch result {
				case .success(let imagesList):
					if let list = imagesList?.hits {
						self.imagesList = list
						self.view?.loadImagesListSucsess()
					}
				case .failure(let error):
					print(error.localizedDescription)
				}
			}
		}
	}

	func setImageForCellImageView(_ imageView: UIImageView, forIndexPath indexPath: IndexPath) {
		let index = indexPath.row
		if index >= imagesList.count { return }
		guard let imageStringURL = imagesList[index].imageURL, let imageURL = URL(string: imageStringURL)  else { return }
		networkService.getImageFromURL(imageURL) { result in
			switch result {
			case .success(let image):
				DispatchQueue.main.async {
					imageView.contentMode = UIImageView.ContentMode.scaleAspectFit
					imageView.image = image
				}
			case .failure(let error):
				print(error.localizedDescription)
				return
			}
		}
	}
	
	func didSelectCell(_ cell: UICollectionViewCell) {
		if let imageView = cell.backgroundView as? UIImageView, let image = imageView.image {
			completion(ImageAndLink(image: image, link: imagesList[cell.tag].imageURL ?? ""))
			view?.cancellButtonTapped()
		}
	}
	
}
