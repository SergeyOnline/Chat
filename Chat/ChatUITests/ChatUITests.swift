//
//  ChatUITests.swift
//  ChatUITests
//
//  Created by Сергей on 06.12.2021.
//

import XCTest

class ChatUITests: XCTestCase {
	
	let app = XCUIApplication()

    override func setUpWithError() throws {
		try super.setUpWithError()
        continueAfterFailure = false

		app.launch()
    }
	
	func testProfileIsNameTextFieldExist() throws {

		app.tabBars[AccessibilityIdentifiers.TabBarScreen.tabBar].buttons[AccessibilityIdentifiers.TabBarScreen.profileButton].tap()
		
		XCTAssertTrue(app.textFields[AccessibilityIdentifiers.ProfileScreen.nameTextField].exists)
	}
	
	func testProfileIsInfoTextViewExist() throws {
		
		app.tabBars[AccessibilityIdentifiers.TabBarScreen.tabBar].buttons[AccessibilityIdentifiers.TabBarScreen.profileButton].tap()
				
		XCTAssertTrue(app.textViews[AccessibilityIdentifiers.ProfileScreen.infoTextView].exists)
	}

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
