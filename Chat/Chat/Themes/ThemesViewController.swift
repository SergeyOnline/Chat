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
		static let theme4ButtonTitle = "theme4ButtonTitle"
	}
	
	private enum Constants {
		static let buttonsCornerRadius = 10.0
	}
	
	private var headerView = UIView()
	
	private lazy var theme1Button: UIButton = {
		let button = UIButton(type: .system)
		button.layer.cornerRadius = Constants.buttonsCornerRadius
		button.tag = 1
		button.setTitle(NSLocalizedString(LocalizeKeys.theme1ButtonTitle, comment: ""), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(themeButtonsAction(_:)), for: .touchUpInside)
		return button
	}()
	
	private lazy var theme2Button: UIButton = {
		let button = UIButton(type: .system)
		button.layer.cornerRadius = Constants.buttonsCornerRadius
		button.tag = 2
		button.setTitle(NSLocalizedString(LocalizeKeys.theme2ButtonTitle, comment: ""), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(themeButtonsAction(_:)), for: .touchUpInside)
		return button
	}()
	
	private lazy var theme3Button: UIButton = {
		let button = UIButton(type: .system)
		button.layer.cornerRadius = Constants.buttonsCornerRadius
		button.tag = 3
		button.setTitle(NSLocalizedString(LocalizeKeys.theme3ButtonTitle, comment: ""), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(themeButtonsAction(_:)), for: .touchUpInside)
		return button
	}()
	
	private lazy var theme4Button: UIButton = {
		let button = UIButton(type: .system)
		button.layer.cornerRadius = Constants.buttonsCornerRadius
		button.tag = 4
		button.setTitle(NSLocalizedString(LocalizeKeys.theme4ButtonTitle, comment: ""), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(themeButtonsAction(_:)), for: .touchUpInside)
		button.isHidden = true
		return button
	}()
	
	private lazy var closeButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle(NSLocalizedString(LocalizeKeys.closeButtonTitle, comment: ""), for: .normal)
		button.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	var completion: (() -> Void) = {}
	
	private var timer: Timer?
	private var emblemLocation = CGPoint.zero
	private var startTime: Date?
	private var isNeedAnimate = true
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = TableViewCellAppearance.backgroundColor.uiColor()
		setup()
    }
    
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		guard let touch = touches.first else { return }
		emblemLocation = touch.location(in: view)
		startTime = Date()
		timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { _ in
			self.createAndAnimateImageView(location: self.emblemLocation)
			self.secretThemeHandle()
		})
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		timer?.invalidate()
		timer = nil
		emblemLocation = .zero
		
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		guard let touch = touches.first else { return }
		emblemLocation = touch.location(in: view)
		createAndAnimateImageView(location: self.emblemLocation)

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
		theme4Button.backgroundColor = NavigationBarAppearance.backgroundColor.uiColor()
		theme4Button.setTitleColor(NavigationBarAppearance.elementsColor.uiColor(), for: .normal)
		closeButton.setTitleColor(NavigationBarAppearance.elementsColor.uiColor(), for: .normal)
		
	}
	
	// MARK: - Actions
	
	@objc func closeButtonAction(_ sender: UIButton) {
		dismiss(animated: true, completion: nil)
	}
	
	@objc func themeButtonsAction(_ sender: UIButton) {
		switch sender.tag {
		case 1:
			Theme.theme = .light
			UserDefaults.standard.set(Themes.light.rawValue, forKey: UserDefaultsKeys.theme)
		case 2:
			Theme.theme = .dark
			UserDefaults.standard.set(Themes.dark.rawValue, forKey: UserDefaultsKeys.theme)
		case 3:
			Theme.theme = .darkBlue
			UserDefaults.standard.set(Themes.darkBlue.rawValue, forKey: UserDefaultsKeys.theme)
		case 4:
			Theme.theme = .pink
			UserDefaults.standard.set(Themes.pink.rawValue, forKey: UserDefaultsKeys.theme)
		default: Theme.theme = .light
		}
		viewWillAppear(true)
		completion()
	}
	
	// MARK: - Private functions
	private func setup() {
		
		headerView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(headerView)
		
		setupHeaderViewConstraints()

		headerView.addSubview(closeButton)
		setupCloseButtonConstraints()
		
		view.addSubview(theme1Button)
		view.addSubview(theme2Button)
		view.addSubview(theme3Button)
		view.addSubview(theme4Button)
		
		setupTheme2ButtonConstraints()
		setupTheme1ButtonConstraints()
		setupTheme3ButtonConstraints()
		setupTheme4ButtonConstraints()
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
	
	private func setupTheme4ButtonConstraints() {
		theme4Button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		theme4Button.centerYAnchor.constraint(equalTo: theme2Button.centerYAnchor, constant: 80).isActive = true
		theme4Button.widthAnchor.constraint(equalTo: theme2Button.widthAnchor).isActive = true
		theme4Button.heightAnchor.constraint(equalTo: theme2Button.heightAnchor).isActive = true
	}
	
	private func createAndAnimateImageView(location: CGPoint) {
		guard let image = UIImage(named: "emblem") else { return }
		let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
		imageView.layer.cornerRadius = 15
		imageView.clipsToBounds = true
		imageView.contentMode = .scaleAspectFit
		imageView.layer.borderWidth = 0.5
		imageView.layer.borderColor = UIColor.black.cgColor
		imageView.image = image
		imageView.center = location
		view.addSubview(imageView)
		imageView.layer.opacity = 1.0
		
		var center = imageView.layer.position
		
		UIView.animate(withDuration: 1.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut) {
			center.x += CGFloat(arc4random_uniform(100)) - CGFloat(arc4random_uniform(100))
			center.y += CGFloat(arc4random_uniform(100)) - CGFloat(arc4random_uniform(100))
			imageView.layer.opacity = 0.0
			imageView.center = center
		} completion: { _ in
			imageView.removeFromSuperview()
		}
	}
	
	private func getUnicornImageCoordinate(forViewNumber number: Int) -> CGPoint {
		var point = CGPoint.zero
		switch number {
		case 0:
			point.x = 60
			point.y = 150
		case 1:
			point.x = self.view.frame.width - 80
			point.y = 180
		case 2:
			point.x = 85
			point.y = self.view.frame.height - 110
		case 3:
			point.x = self.view.frame.width - 60
			point.y = self.view.frame.height - 80
		default: break
		}
		return point
	}
	
	private func secretThemeHandle() {
		guard let start = self.startTime else { return }
		if Date().timeIntervalSince(start) > 5 {
			if self.isNeedAnimate {
				let originPosition = self.theme3Button.center
				var leftPosition = originPosition
				leftPosition.x -= self.view.frame.width
				var rightPosition = originPosition
				rightPosition.x += self.view.frame.width
				self.theme4Button.center = rightPosition
				self.theme4Button.alpha = 0.0
				self.theme4Button.isHidden = false
				UIButton.animateKeyframes(withDuration: 0.5, delay: 0, options: []) {
					UIButton.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1.0) {
						self.theme3Button.center = leftPosition
						self.theme3Button.alpha = 0.0
						self.theme4Button.center = originPosition
						self.theme4Button.alpha = 1.0
					}
				} completion: { _ in
					self.theme3Button.isHidden = true
					for i in 0..<4 {
						let imageView = UIImageView(image: UIImage(named: "unicorn"))
						if i % 2 == 0 {
							imageView.image = imageView.image?.withHorizontallyFlippedOrientation()
						}
						imageView.contentMode = .scaleAspectFit
						let frame = CGRect(x: 0, y: 0, width: 8, height: 8)
						imageView.frame = frame
						imageView.center = self.getUnicornImageCoordinate(forViewNumber: i)
						imageView.alpha = 0.0
						self.view.addSubview(imageView)
						let delay = CGFloat(i) / 10.0
						
						UIImageView.animateKeyframes(withDuration: 2.0, delay: delay, options: UIImageView.KeyframeAnimationOptions.calculationModeLinear) {
							UIImageView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
								imageView.alpha = 1.0
								imageView.transform = CGAffineTransform(scaleX: 10.0, y: 10.0)
							}
							UIImageView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
								imageView.alpha = 0.0
								imageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
							}
						} completion: { _ in
							imageView.removeFromSuperview()
							Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
								self.theme3Button.center = rightPosition
								self.theme3Button.isHidden = false
								UIButton.animateKeyframes(withDuration: 0.5, delay: 0, options: []) {
									UIButton.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1.0) {
										self.theme4Button.center = leftPosition
										self.theme4Button.alpha = 0.0
										self.theme3Button.center = originPosition
										self.theme3Button.alpha = 1.0
									}
								} completion: { _ in
									self.theme4Button.isHidden = true
								}
							}
						}
					}
				}
			}
			self.isNeedAnimate = false
		}
	}
	
}
