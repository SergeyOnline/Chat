//
//  TabBarController.swift
//  Chat
//
//  Created by Сергей on 23.10.2021.
//

import UIKit

class TabBarController: UITabBarController {

	private enum Constants {
		static let settingsButtonImageName = "Gear"
	}
	
	private enum LocalizeKeys {
		static let navigationItemTitle = "navigationItemTitle"
	}
	
	let conversationsListVC = ConversationsListViewController()
	let profileVC = ProfileViewController()
	private lazy var settingsBarButtonItem: UIBarButtonItem = {
		let image = UIImage(named: Constants.settingsButtonImageName)
		let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(settingsBarButtonAction(_:)))
		return item
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
	
		conversationsListVC.tabBarItem.title = "List"
		profileVC.tabBarItem.title = "Profile"
		
//		self.tabBar.backgroundColor = .systemGray6
		self.setViewControllers([conversationsListVC, profileVC], animated: false)
		self.selectedIndex = 0
//		self.view.backgroundColor = .lightGray
		
		navigationItem.title = NSLocalizedString(LocalizeKeys.navigationItemTitle, comment: "")
		navigationItem.backButtonTitle = ""
		
		navigationItem.leftBarButtonItem = settingsBarButtonItem
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tabBar.barTintColor = NavigationBarAppearance.backgroundColor.uiColor()
		tabBar.tintColor = NavigationBarAppearance.elementsColor.uiColor()
		conversationsListVC.viewWillAppear(false)
		profileVC.updateTheme()
	}
	
	override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
		if item == profileVC.tabBarItem {
			navigationItem.leftBarButtonItem = nil
			navigationItem.title = ""
		} else {
			navigationItem.title = NSLocalizedString(LocalizeKeys.navigationItemTitle, comment: "")
			navigationItem.leftBarButtonItem = settingsBarButtonItem
		}
	}
	
	// MARK: - Actions
	@objc func settingsBarButtonAction(_ sender: UIBarButtonItem) {
		let themesVC = ThemesViewController()
		themesVC.modalPresentationStyle = .fullScreen
		themesVC.completion = {
			self.conversationsListVC.tableView.reloadData()
			self.viewWillAppear(false)
			//			self.logThemeChanging()
		}
		present(themesVC, animated: true, completion: nil)
	}

}
