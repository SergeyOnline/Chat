//
//  ChatTests.swift
//  ChatTests
//
//  Created by Сергей on 06.12.2021.
//

import XCTest

class ChatTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func testNetworkServiceWithBadApiKeyTimeout3() throws {
		let networkService = NetworkService(apiKey: "wrongApiKey")
		let promise = XCTestExpectation()
		var error: Error?
		networkService.getImagesList(completion: { result in
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
	
	func testNetworkServiceImagesListNotNilWtithCorrectApiKeyTimeout3() throws {
		let networkService = NetworkService(apiKey: APIKey.key)
		let promise = XCTestExpectation()
		var imageList: ImagesList?
		networkService.getImagesList(completion: { result in
			switch result {
			case .success(let imgList):
				imageList = imgList
				promise.fulfill()
			default: break
			}
		})
		
		wait(for: [promise], timeout: 3)
		XCTAssertNotNil(imageList)
	}

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
