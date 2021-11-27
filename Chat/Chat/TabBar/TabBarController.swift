//
//  TabBarController.swift
//  Chat
//
//  Created by Сергей on 23.10.2021.
//

import UIKit
import Firebase

final class TabBarController: UITabBarController {

	private enum Constants {
		static let settingsButtonImageName = "Gear"
		static let settingsButtonSystemImageName = "gearshape"
		static let profileItemImage = "person"
		static let profileItemImageFill = "person.fill"
		static let channelsItemImage = "message"
		static let channelsItemImageFill = "message.fill"
		static let channelsDBCollection = "channels"
	}
	
	private enum LocalizeKeys {
		static let navigationItemTitle = "navigationItemTitle"
		static let profileItenTitle = "profile"
		static let channelsItemTitle = "channels"
		static let alertOkActionTitle = "alertOkActionTitle"
		static let alertCancelActionTitle = "alertCancelActionTitle"
		static let alertTitle = "alertTitle"
		static let alertMessage = "alertMessage"
		static let alertPlaceholder = "alertPlaceholder"
	}
	
	let conversationsListVC = ConversationsListViewController()
	let profileVC = ProfileViewController()
	
	private lazy var db = Firestore.firestore()
	private lazy var referenceChannel = db.collection(Constants.channelsDBCollection)
	
	private var alertTextMessage = ""
	
	private lazy var settingsBarButtonItem: UIBarButtonItem = {
		var image: UIImage?
		if #available(iOS 13.0, *) {
			image = UIImage(systemName: Constants.settingsButtonSystemImageName)
		} else {
			image = UIImage(named: Constants.settingsButtonImageName)
		}
		
		let item = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(settingsBarButtonAction(_:)))
		return item
	}()
	
	private lazy var addChannelBarButtonItem: UIBarButtonItem = {
		let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addChannelBarButtonAction(_:)))
		return item
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		delegate = self
		conversationsListVC.tabBarItem.title = NSLocalizedString(LocalizeKeys.channelsItemTitle, comment: "")
		if #available(iOS 13.0, *) {
			conversationsListVC.tabBarItem.image = UIImage(systemName: Constants.channelsItemImageFill)
		}
		profileVC.tabBarItem.title = NSLocalizedString(LocalizeKeys.profileItenTitle, comment: "")
		if #available(iOS 13.0, *) {
			profileVC.tabBarItem.image = UIImage(systemName: Constants.profileItemImage)
		}
		
		self.setViewControllers([conversationsListVC, profileVC], animated: false)
		self.selectedIndex = 0
		
		navigationItem.title = NSLocalizedString(LocalizeKeys.navigationItemTitle, comment: "")
		navigationItem.backButtonTitle = ""
		
		navigationItem.leftBarButtonItem = settingsBarButtonItem
		navigationItem.rightBarButtonItem = addChannelBarButtonItem
		
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
			navigationItem.rightBarButtonItem = nil
			navigationItem.title = ""
			if #available(iOS 13.0, *) {
				conversationsListVC.tabBarItem.image = UIImage(systemName: Constants.channelsItemImage)
				profileVC.tabBarItem.image = UIImage(systemName: Constants.profileItemImageFill)
			}
		} else {
			navigationItem.title = NSLocalizedString(LocalizeKeys.navigationItemTitle, comment: "")
			navigationItem.leftBarButtonItem = settingsBarButtonItem
			navigationItem.rightBarButtonItem = addChannelBarButtonItem
			if #available(iOS 13.0, *) {
				conversationsListVC.tabBarItem.image = UIImage(systemName: Constants.channelsItemImageFill)
				profileVC.tabBarItem.image = UIImage(systemName: Constants.profileItemImage)
			}
		}
	}
	
	private func addChannelWhithName(_ name: String) {
		referenceChannel.addDocument(data: [
			"name": name
		]) { err in
			if let err = err {
				print("Error adding document: \(err)")
			}
		}
	}
	
	// MARK: - Actions
	@objc func settingsBarButtonAction(_ sender: UIBarButtonItem) {
		let themesVC = ThemesViewController()
		themesVC.modalPresentationStyle = .fullScreen
		themesVC.completion = {
			self.conversationsListVC.tableView.reloadData()
			self.viewWillAppear(false)
		}
		present(themesVC, animated: true, completion: nil)
	}
	
	@objc func addChannelBarButtonAction(_ sender: UIBarButtonItem) {
		
		let alert = UIAlertController(title: NSLocalizedString(LocalizeKeys.alertTitle, comment: ""),
									  message: NSLocalizedString(LocalizeKeys.alertMessage, comment: ""),
									  preferredStyle: .alert)
		alert.setThemeOptions(viewBackground: TableViewCellAppearance.backgroundColor.uiColor(),
							   titleColor: NavigationBarAppearance.elementsColor.uiColor(),
							   buttonsBackground: NavigationBarAppearance.backgroundColor.uiColor(),
							   tintColor: NavigationBarAppearance.elementsColor.uiColor())
		alert.addTextField { textField in
			textField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString(LocalizeKeys.alertPlaceholder, comment: ""),
																 attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
			textField.superview?.backgroundColor = TableViewCellAppearance.backgroundColor.uiColor()
			textField.backgroundColor = TableViewCellAppearance.backgroundColor.uiColor()
			textField.textColor = NavigationBarAppearance.elementsColor.uiColor()
			textField.addTarget(self, action: #selector(self.textFieldEditing(_:)), for: .editingChanged)
		}
		
		let okAction = UIAlertAction(title: NSLocalizedString(LocalizeKeys.alertOkActionTitle, comment: ""), style: .default) { _ in
			if self.alertTextMessage.isEmpty {
				self.addChannelBarButtonAction(self.addChannelBarButtonItem)
			} else {
				self.addChannelWhithName(self.alertTextMessage)
				self.alertTextMessage = ""
			}
		}
		
		let cancellAction = UIAlertAction(title: NSLocalizedString(LocalizeKeys.alertCancelActionTitle, comment: ""), style: .cancel, handler: nil)
		
		alert.addAction(okAction)
		alert.addAction(cancellAction)
		self.present(alert, animated: true, completion: nil)
	}
	
	@objc func textFieldEditing(_ sender: UITextField) {
		if (sender.text?.count ?? 0) > 20 {
			sender.text?.removeLast()
		}
		self.alertTextMessage = sender.text ?? ""
	}
}
