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
			guard let value = newValue else { return }
			messageLabel.text = value
		}
	}
	
	var messageLabel: UILabel = {
		let label = UILabel()
		label.clipsToBounds = true
		label.layer.cornerRadius = Constants.messageLabelCornerRadius
		label.textColor = .black
		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
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
		contentView.backgroundColor = TableViewCellAppearance.backgroundColor.uiColor()
		
		let wrapperMessageLabelStack = CustomStackView(axis: .vertical, distribution: .equalCentering)
		wrapperMessageLabelStack.addArrangedSubview(messageLabel)
		messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: contentView.frame.width * 0.75).isActive = true
		wrapperMessageLabelStack.translatesAutoresizingMaskIntoConstraints = false
		wrapperMessageLabelStack.layoutMargins = UIEdgeInsets(top: Constants.vStackUniversalOffset,
											left: Constants.vStackUniversalOffset,
											bottom: Constants.vStackUniversalOffset,
											right: Constants.vStackUniversalOffset)
		wrapperMessageLabelStack.isLayoutMarginsRelativeArrangement = true
		if #available(iOS 14.0, *) {
			wrapperMessageLabelStack.layer.cornerRadius = Constants.vStackCornerRadius
		}
		
		self.contentView.addSubview(wrapperMessageLabelStack)
		wrapperMessageLabelStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.vStackUniversalOffset).isActive = true
		wrapperMessageLabelStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.vStackUniversalOffset).isActive = true
		
		if reuseIdentifier == Constants.InputReuseIdentifier {
			if #available(iOS 14.0, *) {
				wrapperMessageLabelStack.backgroundColor = Constants.inputMessageBackgroundColor
			} else {
				messageLabel.backgroundColor = Constants.inputMessageBackgroundColor
			}
			wrapperMessageLabelStack.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Constants.vStackUniversalOffset).isActive = true
		} else {
			if #available(iOS 14.0, *) {
				wrapperMessageLabelStack.backgroundColor = Constants.outputMessageBackgroundColor
			} else {
				messageLabel.backgroundColor = Constants.outputMessageBackgroundColor
			}
			wrapperMessageLabelStack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Constants.vStackUniversalOffset).isActive = true
		}
	}
	
}

