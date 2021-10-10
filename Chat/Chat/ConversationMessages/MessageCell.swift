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
	
	private enum Constants {
		static let vStackUniversalOffset = 10.0
		static let vStackCornerRadius = 10.0
		static let InputReuseIdentifier = "input"
		static let messageLabelCornerRadius = 8.0
		static let inputMessageBackgroundColor = UIColor(red: 0.875, green: 0.875, blue: 0.875, alpha: 1)
		static let outputMessageBackgroundColor = UIColor(red: 0.863, green: 0.969, blue: 0.773, alpha: 1)
	}
	
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
		messageLabel.layer.cornerRadius = Constants.messageLabelCornerRadius
		messageLabel.textColor = .black
		messageLabel.numberOfLines = 0
		messageLabel.lineBreakMode = .byWordWrapping
		messageLabel.translatesAutoresizingMaskIntoConstraints = false
		
		let vStack = CustomStackView(axis: .vertical, distribution: .equalCentering)
		vStack.addArrangedSubview(messageLabel)
		vStack.translatesAutoresizingMaskIntoConstraints = false
		vStack.layoutMargins = UIEdgeInsets(top: Constants.vStackUniversalOffset,
											left: Constants.vStackUniversalOffset,
											bottom: Constants.vStackUniversalOffset,
											right: Constants.vStackUniversalOffset)
		vStack.isLayoutMarginsRelativeArrangement = true
		vStack.layer.cornerRadius = Constants.vStackCornerRadius
		
		self.contentView.addSubview(vStack)
		vStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.vStackUniversalOffset).isActive = true
		vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.vStackUniversalOffset).isActive = true
		
		if reuseIdentifier == Constants.InputReuseIdentifier {
			vStack.backgroundColor = Constants.inputMessageBackgroundColor
			vStack.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Constants.vStackUniversalOffset).isActive = true
		} else {
			vStack.backgroundColor = Constants.outputMessageBackgroundColor
			vStack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Constants.vStackUniversalOffset).isActive = true
		}
		
	}
}
