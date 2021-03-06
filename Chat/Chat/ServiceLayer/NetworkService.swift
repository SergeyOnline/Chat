//
//  NetworkService.swift
//  Chat
//
//  Created by Сергей on 20.11.2021.
//

import Foundation
import UIKit

enum NetworkError: Error {
	case badURL
	case dataError
	case badImage
	case badStatusCode
	
	var localizedDescription: String {
		switch self {
		case .badURL:
			return "Bad URL address"
		case .dataError:
			return "Error loading data"
		case .badImage:
			return "Error loading image"
		case .badStatusCode:
			return "Invalid server response status code"
		}
	}

}

protocol IImageLoaderAPI {
	var host: String { get }
	var parameters: String { get }
}

struct ImageLoaderAPI: IImageLoaderAPI {
	private let bundle = Bundle.main
	
	var host: String {
		return bundle.pixabayHost
	}
	
	var parameters: String {
		return bundle.pixabayParameters
	}
}

protocol NetworkServiceProtocol {
	init(imageLoaderAPI: IImageLoaderAPI)
//	init(apiKey: String)
	func getImagesList(completion: @escaping (Result<ImagesList?, Error>) -> Void)
	func getImageFromURL(_ url: URL, completion: @escaping (Result<UIImage?, Error>) -> Void)
}

final class NetworkService: NetworkServiceProtocol {
	
//	let apiKey: String
//
//	required init(apiKey: String) {
//		self.apiKey = apiKey
//	}
	let imageLoaderAPI: IImageLoaderAPI
	
	required init(imageLoaderAPI: IImageLoaderAPI) {
		self.imageLoaderAPI = imageLoaderAPI
	}
	
	func getImagesList(completion: @escaping (Result<ImagesList?, Error>) -> Void) {
		
		guard let url = URL(string: "https://\(imageLoaderAPI.host)\(imageLoaderAPI.parameters)") else {
			completion(.failure(NetworkError.badURL))
			return
		}

		let request = URLRequest(url: url)
		let session = URLSession.shared
		let task = session.dataTask(with: request) { data, response, error in
			if let error = error {
				completion(.failure(error))
			}
			if let response = response as? HTTPURLResponse {
				if response.statusCode != 200 {
					completion(.failure(NetworkError.badStatusCode))
				}
			}

			guard let data = data else {
				completion(.failure(NetworkError.dataError))
				return
			}

			do {
				let json = try JSONDecoder().decode(ImagesList.self, from: data)
				completion(.success(json))
			} catch {
				completion(.failure(error))
			}

		}
		task.resume()
	}

	func getImageFromURL(_ url: URL, completion: @escaping (Result<UIImage?, Error>) -> Void) {

		let request = URLRequest(url: url)
		let session = URLSession.shared
		let task = session.dataTask(with: request) { data, response, error in
			if let error = error {
				completion(.failure(error))
			}

			if let response = response as? HTTPURLResponse {
				if response.statusCode != 200 {
					completion(.failure(NetworkError.badStatusCode))
				}
			}

			guard let data = data else {
				completion(.failure(NetworkError.dataError))
				return
			}

			if let image = UIImage(data: data) {
				completion(.success(image))
			} else {
				completion(.failure(NetworkError.badImage))
			}
		}
		task.resume()
	}
}
