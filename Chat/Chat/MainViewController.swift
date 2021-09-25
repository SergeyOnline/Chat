//
//  MainViewController.swift
//  Chat
//
//  Created by Сергей on 24.09.2021.
//

import UIKit

class MainViewController: UIViewController {
	
	private let reuseIdentifier = "Cell"
	
	var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.title = "Chat"
		
		let userImageView = UserImageView(labelTitle: User().initials, labelfontSize: 20)
		userImageView.layer.cornerRadius = 20
	
		
		let profileBarButtonItem = UIBarButtonItem(customView: userImageView)
		profileBarButtonItem.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileBarButtonAction)))
		userImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
		userImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
	
		self.navigationItem.rightBarButtonItem = profileBarButtonItem

		

		tableView = UITableView(frame: self.view.frame, style: .plain)
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
		tableView.delegate = self
		tableView.dataSource = self

		self.view.addSubview(tableView)
    }

	//MARK: - Actions
	@objc func profileBarButtonAction(_ sender: UIBarButtonItem) {
		let profileViewController = ProfileViewController()
		self.present(profileViewController, animated: true, completion: nil)
	}

}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {

	// MARK: - Table view data source
	func numberOfSections(in tableView: UITableView) -> Int {
		return 0
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

		return cell
	}

}
