//
//  ThemesViewController.swift
//  Chat
//
//  Created by Сергей on 10.10.2021.
//

import UIKit

class ThemesViewController: UIViewController {

	private enum LocalizeKeys {
		static let closeButtonTitle = "closeButtonTitle"
		static let theme1ButtonTitle = "theme1ButtonTitle"
		static let theme2ButtonTitle = "theme2ButtonTitle"
		static let theme3ButtonTitle = "theme3ButtonTitle"
	}
	
	private var headerView: UIView!
	private var theme1Button: UIButton!
	private var theme2Button: UIButton!
	private var theme3Button: UIButton!
	
	var completion: (()-> Void)!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = TableViewCellAppearance.backgroundColor.uiColor()

		setup()
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		view.backgroundColor = TableViewCellAppearance.backgroundColor.uiColor()
		headerView.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		theme1Button.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		theme2Button.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		theme3Button.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		
	}
	
	//MARK: - Actions
	
	@objc func closeButtonAction(_ sender: UIButton) {
		dismiss(animated: true, completion: nil)
	}
	
	@objc func themeButtonsAction(_ sender: UIButton) {
		switch sender.tag {
		case 1:
			Theme.theme = .light
			UserDefaults.standard.set(1, forKey: UserDefaultsKeys.theme)
		case 2:
			Theme.theme = .dark
			UserDefaults.standard.set(2, forKey: UserDefaultsKeys.theme)
		case 3:
			Theme.theme = .darkBlue
			UserDefaults.standard.set(3, forKey: UserDefaultsKeys.theme)
		default: Theme.theme = .light
		}
		viewWillAppear(true)
		completion()
	}
	
	//MARK: - Private functions
	private func setup() {
		headerView = UIView()
		headerView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(headerView)
		
		headerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		headerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		headerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		headerView.heightAnchor.constraint(equalToConstant: 88).isActive = true
		
		let closeButton = UIButton(type: .system)
		closeButton.setTitle(NSLocalizedString(LocalizeKeys.closeButtonTitle, comment: ""), for: .normal)
		closeButton.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
		closeButton.translatesAutoresizingMaskIntoConstraints = false
		
		headerView.addSubview(closeButton)
		closeButton.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -10).isActive = true
		closeButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10).isActive = true
		closeButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
		closeButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
		
		theme1Button = UIButton(type: .system)
		theme1Button.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		theme1Button.tag = 1
		theme1Button.setTitle(NSLocalizedString(LocalizeKeys.theme1ButtonTitle, comment: ""), for: .normal)
		theme1Button.translatesAutoresizingMaskIntoConstraints = false
		theme1Button.addTarget(self, action: #selector(themeButtonsAction(_:)), for: .touchUpInside)
		
		theme2Button = UIButton(type: .system)
		theme2Button.tag = 2
		theme2Button.setTitle(NSLocalizedString(LocalizeKeys.theme2ButtonTitle, comment: ""), for: .normal)
		theme2Button.translatesAutoresizingMaskIntoConstraints = false
		theme2Button.addTarget(self, action: #selector(themeButtonsAction(_:)), for: .touchUpInside)
		
		theme3Button = UIButton(type: .system)
		theme3Button.tag = 3
		theme3Button.setTitle(NSLocalizedString(LocalizeKeys.theme3ButtonTitle, comment: ""), for: .normal)
		theme3Button.translatesAutoresizingMaskIntoConstraints = false
		theme3Button.addTarget(self, action: #selector(themeButtonsAction(_:)), for: .touchUpInside)
		
		view.addSubview(theme1Button)
		view.addSubview(theme2Button)
		view.addSubview(theme3Button)
		
		theme2Button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		theme2Button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		theme2Button.widthAnchor.constraint(equalToConstant: view.frame.width / 2).isActive = true
		theme2Button.heightAnchor.constraint(equalToConstant: 40).isActive = true
		
		theme1Button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		theme1Button.centerYAnchor.constraint(equalTo: theme2Button.centerYAnchor, constant: -80).isActive = true
		theme1Button.widthAnchor.constraint(equalTo: theme2Button.widthAnchor).isActive = true
		theme1Button.heightAnchor.constraint(equalTo: theme2Button.heightAnchor).isActive = true
		
		theme3Button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		theme3Button.centerYAnchor.constraint(equalTo: theme2Button.centerYAnchor, constant: 80).isActive = true
		theme3Button.widthAnchor.constraint(equalTo: theme2Button.widthAnchor).isActive = true
		theme3Button.heightAnchor.constraint(equalTo: theme2Button.heightAnchor).isActive = true
	}

}
