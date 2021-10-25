//
//  UserImageView.swift
//  Chat
//
//  Created by Сергей on 25.09.2021.
//

import UIKit

final class UserImageView: UIImageView {

	private var statusView: UIView = {
		let view = UIView()
		view.layer.borderWidth = 2
		view.layer.borderColor = UIColor.white.cgColor
		view.backgroundColor = .green
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = 6
		view.clipsToBounds = false
		view.isHidden = true
		return view
	}()
	
	private var initialLabel: ProfileLabel
	
	init(labelTitle: String, labelfontSize: CGFloat) {
		
		initialLabel = ProfileLabel(text: labelTitle, font: UIFont.systemFont(ofSize: labelfontSize))
		super.init(image: nil)
		backgroundColor = UIColor(red: 0.894, green: 0.908, blue: 0.17, alpha: 1)
		clipsToBounds = true
		translatesAutoresizingMaskIntoConstraints = false
	
		initialLabel.translatesAutoresizingMaskIntoConstraints = false
		addSubview(initialLabel)
		initialLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		initialLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		
		addSubview(statusView)
		statusView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		statusView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
		statusView.heightAnchor.constraint(equalToConstant: 12).isActive = true
		statusView.widthAnchor.constraint(equalToConstant: 12).isActive = true
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}

extension UserImageView {
	
	enum Status {
		case online
		case offline
	}
	
	func changeUserStatusTo(_ status: Status) {
		switch status {
		case .online:
			statusView.isHidden = false
		case .offline:
			statusView.isHidden = true
		}
	}
	
	func setInitials(initials: String) {
		initialLabel.text = initials.uppercased()
	}
}
