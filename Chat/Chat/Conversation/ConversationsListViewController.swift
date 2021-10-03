//
//  MainViewController.swift
//  Chat
//
//  Created by Сергей on 24.09.2021.
//

import UIKit

class ConversationsListViewController: UIViewController {
	
	private let reuseIdentifier = "Cell"
	
	var tableView: UITableView!

	override func viewDidLoad() {
        super.viewDidLoad()
		
		
		self.view.backgroundColor = .systemGray
		self.navigationItem.title = NSLocalizedString("navigationItemTitle", comment: "")
		
		let userImageView = UserImageView(labelTitle: Owner().initials, labelfontSize: 20)
		userImageView.layer.cornerRadius = 20
	
		
		let profileBarButtonItem = UIBarButtonItem(customView: userImageView)
		profileBarButtonItem.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileBarButtonAction(_:))))
		userImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
		userImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
		
		let image = UIImage(named: "Gear")
		let settingsBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(settingsBarButtonAction(_sender:)))
	
		self.navigationItem.rightBarButtonItem = profileBarButtonItem
		self.navigationItem.leftBarButtonItem = settingsBarButtonItem

		
		tableView = UITableView(frame: self.view.safeAreaLayoutGuide.layoutFrame, style: .grouped)

		tableView.register(ConversationCell.self, forCellReuseIdentifier: reuseIdentifier)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 80

		self.view.addSubview(tableView)
    }

	//MARK: - Actions
	@objc func profileBarButtonAction(_ sender: UIBarButtonItem) {
		let profileViewController = ProfileViewController()
		self.present(profileViewController, animated: true, completion: nil)
	}
	
	@objc func settingsBarButtonAction(_sender: UIBarButtonItem) {
		//TODO: - settings
		print("TO DO")
	}

}

extension ConversationsListViewController: UITableViewDelegate, UITableViewDataSource {

	// MARK: - Table view data source
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 1 {
			return 6
		}
		return 10
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ConversationCell

		cell.name = "Test"
		if indexPath.section == 0 {
			cell.message = "This is message\nferfe\nfewrfegr"
			cell.online = true
		} else {
			cell.message = "This is message"
			cell.online = false
		}
		cell.date = Date()
		return cell
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0: return "Online"
		case 1: return "History"
		default: return ""
		}
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}

}
