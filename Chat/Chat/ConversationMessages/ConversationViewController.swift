//
//  ConversationViewController.swift
//  Chat
//
//  Created by Сергей on 05.10.2021.
//

import UIKit

class ConversationViewController: UIViewController {

	var user: User
	weak var delegate: ConversationsListViewControllerDelegate?
	var tableView: UITableView!
	
	private let identifier = "MessageCell"
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.title = user.fullName
		self.navigationController?.navigationBar.tintColor = (traitCollection.userInterfaceStyle == .light) ? .black : .white

		tableView = UITableView(frame: self.view.safeAreaLayoutGuide.layoutFrame, style: .plain)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(MessageCell.self, forCellReuseIdentifier: identifier)
		tableView.separatorStyle = .none
//		if user.messages != nil {
//			let indexPath = IndexPath(row: (user.messages!.count) - 1, section: 0)
//			tableView.scrollToRow(at: indexPath, at: .none, animated: false)
//		}
		
		self.view.addSubview(tableView)
        // Do any additional setup after loading the view.
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		delegate?.changeMessagesForUserWhithID(user.id, to: user.messages)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if user.messages != nil {
			for i in 0..<user.messages!.count {
				user.messages![i].unread = false
			}
		}
	}
    
	init(user: User) {
		self.user = user
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return user.messages?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MessageCell
		
		cell.messageText = user.messages?[indexPath.row].body ?? ""
		cell.owherID = user.messages?[indexPath.row].ownerID ?? 0
		return cell
	}
	
}
