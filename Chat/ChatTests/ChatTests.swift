//
//  ChatTests.swift
//  ChatTests
//
//  Created by Сергей on 06.12.2021.
//

import XCTest
@testable import Chat

class NetworkServiceStub: NetworkServiceProtocol {
	
	enum TestError: Error {
		case someError
	}
	
	private let imageLoaderAPI: IImageLoaderAPI
	
	required init(imageLoaderAPI: IImageLoaderAPI) {
		self.imageLoaderAPI = imageLoaderAPI
	}
	
	func getImagesList(completion: @escaping (Result<ImagesList?, Error>) -> Void) {
		completion(.failure(TestError.someError))
	}
	
	func getImageFromURL(_ url: URL, completion: @escaping (Result<UIImage?, Error>) -> Void) {
		completion(.failure(TestError.someError))
	}
}

class ChatTests: XCTestCase {

    override func setUpWithError() throws {
       try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
	
	func testImagePickerPresenterNetworkServiceGetImageListWithFailure() {
		let view = ImagePickerViewController()
		let networkServiceStub = NetworkServiceStub(imageLoaderAPI: ImageLoaderAPI())
		let sut = ImagePickerPresenter(view: view, networkService: networkServiceStub)
		let promise = XCTestExpectation()
		var error: Error?
		sut.networkService.getImagesList { result in
			switch result {
			case .failure(let err):
				error = err
				promise.fulfill()
			default: break
			}
		}
		
		wait(for: [promise], timeout: 3)
		XCTAssertNotNil(error)
	}
	
	func testImagePickerPresenterNetworkServiceGetImageFromURLWithFailure() {
		let view = ImagePickerViewController()
		let networkServiceStub = NetworkServiceStub(imageLoaderAPI: ImageLoaderAPI())
		let sut = ImagePickerPresenter(view: view, networkService: networkServiceStub)
		let promise = XCTestExpectation()
		var error: Error?
		let url = URL(string: "https://www.apple.com/")!
		sut.networkService.getImageFromURL(url, completion: { result in
			switch result {
			case .failure(let err):
				error = err
				promise.fulfill()
			default: break
			}
		})
		
		wait(for: [promise], timeout: 3)
		XCTAssertNotNil(error)
	}

	// MARK: - Bad tests
//	func testNetworkServiceWithBadApiKeyTimeout3() throws {
//		let networkService = NetworkService(apiKey: "wrongApiKey")
//		let promise = XCTestExpectation()
//		var error: Error?
//		networkService.getImagesList(completion: { result in
//			switch result {
//			case .failure(let err):
//				error = err
//				promise.fulfill()
//			default: break
//			}
//		})
//
//		wait(for: [promise], timeout: 3)
//		XCTAssertNotNil(error)
//	}
//
//	func testNetworkServiceImagesListNotNilWtithCorrectApiKeyTimeout3() throws {
//		let networkService = NetworkService(apiKey: APIKey.key)
//		let promise = XCTestExpectation()
//		var imageList: ImagesList?
//		networkService.getImagesList(completion: { result in
//			switch result {
//			case .success(let imgList):
//				imageList = imgList
//				promise.fulfill()
//			default: break
//			}
//		})
//
//		wait(for: [promise], timeout: 3)
//		XCTAssertNotNil(imageList)
//	}

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
