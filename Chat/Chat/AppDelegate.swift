//
//  AppDelegate.swift
//  Chat
//
//  Created by Сергей on 17.09.2021.
//

import UIKit

enum State: String {
	case active = "active"
	case inactive = "inactive"
	case background = "background"
	case suspended = "not running"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
		
		window = UIWindow()
		
		let conversationsListVC = ConversationsListViewController()
		let navViewController = UINavigationController(rootViewController: conversationsListVC)
		
		
		window?.rootViewController = navViewController
		window?.makeKeyAndVisible()
		PrintStateTransitionFrom(.suspended, to: .inactive)
		
		switch UserDefaults.standard.integer(forKey: UserDefaultsKeys.theme) {
		case 0:
			UserDefaults.standard.set(1, forKey: UserDefaultsKeys.theme)
			Theme.theme = .light
		case 1:
			Theme.theme = .light
		case 2:
			Theme.theme = .dark
		case 3:
			Theme.theme = .darkBlue
		default:
			break
		}
		
		return true
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		
		PrintStateTransitionFrom(.inactive, to: .active)
	}
	
	func applicationWillResignActive(_ application: UIApplication) {

		PrintStateTransitionFrom(.active, to: .inactive)
	}

	func applicationDidEnterBackground(_ application: UIApplication) {

		PrintStateTransitionFrom(.inactive, to: .background)
	}

	func applicationWillEnterForeground(_ application: UIApplication) {

		PrintStateTransitionFrom(.background, to: .inactive)
	}


	func applicationWillTerminate(_ application: UIApplication) {

		PrintStateTransitionFrom(.background, to: .suspended)
	}
	
	
	/**
	Prints the transition state of the application lifecycle
	
	- parameter from: Previous state of the application.
	- parameter to: The current state of the application
	- parameter sender: Method called when the state of the application changes. Default value - #function.
	
	# Notes: #
	1. Method only works with Build Configuration - Debug
	2. To use it, you need to add the DEBUG_LOG_APP_LIFE argument to the schema settings
	*/
	private func PrintStateTransitionFrom(_ from: State, to: State, sender: String = #function) {
		#if DEBUG
		if CommandLine.arguments.contains("DEBUG_LOG_APP_LIFE") {
			print("Application moved from \"\(from.rawValue)\" to \"\(to.rawValue)\": \(sender)")
		}
		#endif
	}

}
