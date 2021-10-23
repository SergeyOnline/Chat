//
//  TabBarController.swift
//  Chat
//
//  Created by Сергей on 23.10.2021.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

		let conversationsListVC = ConversationsListViewController()
		conversationsListVC.tabBarItem.title = "List"
		
		let profileVC = ProfileViewController()
		profileVC.tabBarItem.title = "Profile"
		
//		self.tabBar.backgroundColor = .systemGray6
		self.setViewControllers([conversationsListVC, profileVC], animated: false)
		self.selectedIndex = 0
//		self.view.backgroundColor = .lightGray
    }

}
