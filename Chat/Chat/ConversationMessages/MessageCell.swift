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

class MessageCell: UITableViewCell, MessageCellConfiguration {
	var messageText: String? {
		willSet {
			guard let _ = newValue else { return }
			
			let attributedString = NSMutableAttributedString(string: newValue!)
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.paragraphSpacingBefore = 5
			paragraphStyle.paragraphSpacing = 5
			attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))

			messageLabel.attributedText = attributedString
//			messageLabel.text = newValue!
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
		
		self.selectionStyle = .none
		
		messageLabel = UILabel()
		messageLabel.clipsToBounds = true
		messageLabel.layer.cornerRadius = 8
		messageLabel.textColor = .black
		messageLabel.numberOfLines = 0
		messageLabel.lineBreakMode = .byWordWrapping
		messageLabel.translatesAutoresizingMaskIntoConstraints = false
		
		self.contentView.addSubview(messageLabel)
		messageLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
		messageLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
		
		if reuseIdentifier == "input" {
			messageLabel.backgroundColor = UIColor(red: 0.875, green: 0.875, blue: 0.875, alpha: 1)
			messageLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 10).isActive = true
		} else {
			messageLabel.backgroundColor = UIColor(red: 0.863, green: 0.969, blue: 0.773, alpha: 1)
			messageLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -10).isActive = true
		}
	}
}

