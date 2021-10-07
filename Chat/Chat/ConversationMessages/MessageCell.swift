//
//  MessageCell.swift
//  Chat
//
//  Created by Сергей on 05.10.2021.
//

import UIKit

protocol MessageCellConfiguration: AnyObject {
	var messageText: String? { get set }
}

final class MessageCell: UITableViewCell, MessageCellConfiguration {
	var messageText: String? {
		willSet {
			guard let _ = newValue else { return }
			messageLabel.text = newValue!
		}
	}
	var messageLabel: UILabel!
	var owherID: Int = 0

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	//MARK: - Private functions
	private func setup() {
		
		selectionStyle = .none
		
		messageLabel = UILabel()
		messageLabel.clipsToBounds = true
		messageLabel.layer.cornerRadius = 8
		messageLabel.textColor = .black
		messageLabel.numberOfLines = 0
		messageLabel.lineBreakMode = .byWordWrapping
		messageLabel.translatesAutoresizingMaskIntoConstraints = false
		
		let vStack = CustomStackView(axis: .vertical, distribution: .equalCentering)
		vStack.addArrangedSubview(messageLabel)
		vStack.translatesAutoresizingMaskIntoConstraints = false
		vStack.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		vStack.isLayoutMarginsRelativeArrangement = true
		vStack.layer.cornerRadius = 10
		
		self.contentView.addSubview(vStack)
		vStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
		vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
		
		if reuseIdentifier == "input" {
			vStack.backgroundColor = UIColor(red: 0.875, green: 0.875, blue: 0.875, alpha: 1)
			vStack.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
		} else {
			vStack.backgroundColor = UIColor(red: 0.863, green: 0.969, blue: 0.773, alpha: 1)
			vStack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
		}
		
	}
}

