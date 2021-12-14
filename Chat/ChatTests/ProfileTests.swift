//
//  ProfileTests.swift
//  ChatTests
//
//  Created by Сергей on 09.12.2021.
//

import XCTest
@testable import Chat

class UserProfileHandlerGCDStub: UserProfileInfoHandlerProtocol {
	
	enum TestError: Error {
		case someError
	}
	
	func saveOwnerInfo(owner: Owner, completion: @escaping (Error?) -> Void) {
		completion(TestError.someError)
	}
	
	func loadOwnerInfo(completion: @escaping (Result<Owner, Error>) -> Void) {
		completion(.success(Owner(firstName: "firstName", lastName: "lastName", info: "info")))
	}
	
	func saveOwnerImage(image: UIImage?, completion: @escaping (Error?) -> Void) {
		completion(TestError.someError)
	}
	
	func loadOwnerImage(completion: @escaping (Result<UIImage?, Error>) -> Void) {
		completion(.success(UIImage()))
	}

}

class ProfileTests: XCTestCase {

	override func setUpWithError() throws {
	   try super.setUpWithError()
	}

	override func tearDownWithError() throws {
		try super.tearDownWithError()
	}

	func testProfileUserProfileHandlerGCDLoadOwnerInfoWithSuccsess() {
		let userProfileHandlerGCDStub = UserProfileHandlerGCDStub()
		let sut = ProfileViewController()
		sut.userProfileHandlerGCD = userProfileHandlerGCDStub
		let promise = XCTestExpectation()
		var testOwner: Owner?
		sut.userProfileHandlerGCD.loadOwnerInfo { result in
			switch result {
			case .success(let owner):
				testOwner = owner
				promise.fulfill()
			default: break
			}
		}
		
		wait(for: [promise], timeout: 3)
		XCTAssertTrue(testOwner?.firstName == "firstName" && testOwner?.lastName == "lastName" && testOwner?.info == "info")
	}
	
	func testProfileUserProfileHandlerGCDSaveOwnerInfoWithFailure() {
		let userProfileHandlerGCDStub = UserProfileHandlerGCDStub()
		let sut = ProfileViewController()
		sut.userProfileHandlerGCD = userProfileHandlerGCDStub
		let promise = XCTestExpectation()
		var error: Error?
		sut.userProfileHandlerGCD.saveOwnerInfo(owner: Owner()) { err in
			error = err
			promise.fulfill()
		}
		
		wait(for: [promise], timeout: 3)
		XCTAssertNotNil(error)
	}
	
	func testProfileUserProfileHandlerGCDSaveOwnerImageWithFailure() {
		let userProfileHandlerGCDStub = UserProfileHandlerGCDStub()
		let sut = ProfileViewController()
		sut.userProfileHandlerGCD = userProfileHandlerGCDStub
		let promise = XCTestExpectation()
		var error: Error?
		sut.userProfileHandlerGCD.saveOwnerImage(image: UIImage()) { err in
			error = err
			promise.fulfill()
		}
		
		wait(for: [promise], timeout: 3)
		XCTAssertNotNil(error)
	}
	
	func testProfileUserProfileHandlerGCDLoadOwnerImageWithSuccsess() {
		let userProfileHandlerGCDStub = UserProfileHandlerGCDStub()
		let sut = ProfileViewController()
		sut.userProfileHandlerGCD = userProfileHandlerGCDStub
		let promise = XCTestExpectation()
		var testImage: UIImage?
		sut.userProfileHandlerGCD.loadOwnerImage { result in
			switch result {
			case .success(let image):
				testImage = image
				promise.fulfill()
			default: break
			}
		}
		
		wait(for: [promise], timeout: 3)
		XCTAssertNotNil(testImage)
	}
	
	/*
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
	*/

}
