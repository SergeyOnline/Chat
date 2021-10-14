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
	
	private enum Constants {
		static let buttonsCornerRadius = 10.0
	}
	
	private var headerView: UIView = {
		let view = UIView()
		return view
	}()
	
	private var theme1Button: UIButton = {
		let button = UIButton(type: .system)
		button.layer.cornerRadius = Constants.buttonsCornerRadius
		button.tag = 1
		button.setTitle(NSLocalizedString(LocalizeKeys.theme1ButtonTitle, comment: ""), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(themeButtonsAction(_:)), for: .touchUpInside)
		return button
	}()
	
	private var theme2Button: UIButton = {
		let button = UIButton(type: .system)
		button.layer.cornerRadius = Constants.buttonsCornerRadius
		button.tag = 2
		button.setTitle(NSLocalizedString(LocalizeKeys.theme2ButtonTitle, comment: ""), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(themeButtonsAction(_:)), for: .touchUpInside)
		return button
	}()
	
	private var theme3Button: UIButton = {
		let button = UIButton(type: .system)
		button.layer.cornerRadius = Constants.buttonsCornerRadius
		button.tag = 3
		button.setTitle(NSLocalizedString(LocalizeKeys.theme3ButtonTitle, comment: ""), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(themeButtonsAction(_:)), for: .touchUpInside)
		return button
	}()
	
	private var closeButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle(NSLocalizedString(LocalizeKeys.closeButtonTitle, comment: ""), for: .normal)
		button.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	var completion: (()-> Void) = {}
	
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
		theme1Button.setTitleColor(NavigationBarAppearance.elementsColor.uiColor(), for: .normal)
		theme2Button.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		theme2Button.setTitleColor(NavigationBarAppearance.elementsColor.uiColor(), for: .normal)
		theme3Button.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		theme3Button.setTitleColor(NavigationBarAppearance.elementsColor.uiColor(), for: .normal)
		closeButton.setTitleColor(NavigationBarAppearance.elementsColor.uiColor(), for: .normal)
		
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
		
		headerView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(headerView)
		
		setupHeaderViewConstraints()

		headerView.addSubview(closeButton)
		setupCloseButtonConstraints()
		
		view.addSubview(theme1Button)
		view.addSubview(theme2Button)
		view.addSubview(theme3Button)
		
		setupTheme2ButtonConstraints()
		setupTheme1ButtonConstraints()
		setupTheme3ButtonConstraints()
	}
	
	private func setupHeaderViewConstraints() {
		headerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		headerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		headerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		headerView.heightAnchor.constraint(equalToConstant: 88).isActive = true
	}
	
	private func setupCloseButtonConstraints() {
		closeButton.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -10).isActive = true
		closeButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10).isActive = true
		closeButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
		closeButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
	}
	
	private func setupTheme1ButtonConstraints() {
		theme1Button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		theme1Button.centerYAnchor.constraint(equalTo: theme2Button.centerYAnchor, constant: -80).isActive = true
		theme1Button.widthAnchor.constraint(equalTo: theme2Button.widthAnchor).isActive = true
		theme1Button.heightAnchor.constraint(equalTo: theme2Button.heightAnchor).isActive = true
	}
	
	private func setupTheme2ButtonConstraints() {
		theme2Button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		theme2Button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		theme2Button.widthAnchor.constraint(equalToConstant: view.frame.width / 2).isActive = true
		theme2Button.heightAnchor.constraint(equalToConstant: 40).isActive = true
	}
	
	private func setupTheme3ButtonConstraints() {
		theme3Button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		theme3Button.centerYAnchor.constraint(equalTo: theme2Button.centerYAnchor, constant: 80).isActive = true
		theme3Button.widthAnchor.constraint(equalTo: theme2Button.widthAnchor).isActive = true
		theme3Button.heightAnchor.constraint(equalTo: theme2Button.heightAnchor).isActive = true
	}
	
}
