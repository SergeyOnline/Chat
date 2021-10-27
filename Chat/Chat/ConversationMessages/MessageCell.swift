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
		static let tailImageViewName = "moon.fill"
		static let messageLabelCornerRadius = 8.0
		static let inputMessageBackgroundColor = UIColor(red: 0.875, green: 0.875, blue: 0.875, alpha: 1)
		static let outputMessageBackgroundColor = UIColor(red: 0.863, green: 0.969, blue: 0.773, alpha: 1)
	}
	
	var messageText: String? {
		willSet {
			guard let value = newValue else { return }
			messageLabel.text = value
			nameLabel.textColor = getColorFromName(value.hashValue)
		}
	}
	
	var messageLabel: UILabel = {
		let label = UILabel()
		label.clipsToBounds = true
		label.layer.cornerRadius = Constants.messageLabelCornerRadius
		label.textColor = .black
		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
		return label
	}()
	
	var nameLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: 12)
		label.textColor = .black
		label.numberOfLines = 1
		return label
	}()
	
	var isTailNeed = false {
		didSet {
			setup()
		}
	}
	
	private var tailImageView: UIImageView
	private var wrapperMessageLabelStack = CustomStackView()
		
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		if #available(iOS 14.0, *) {
			let image = UIImage(systemName: Constants.tailImageViewName)
			tailImageView = UIImageView(image: image)
		} else {
			tailImageView = UIImageView()
		}
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		tailImageView.removeFromSuperview()
		wrapperMessageLabelStack.removeFromSuperview()
	}
	
	// MARK: - Private functions
	private func setup() {
		
		selectionStyle = .none
		contentView.backgroundColor = TableViewCellAppearance.backgroundColor.uiColor()
		tailImageView.translatesAutoresizingMaskIntoConstraints = false
		
		wrapperMessageLabelStack = CustomStackView(axis: .vertical, distribution: .equalCentering)
		
		if reuseIdentifier == Constants.InputReuseIdentifier {
			wrapperMessageLabelStack.addArrangedSubview(nameLabel)
		}
		
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
		wrapperMessageLabelStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1).isActive = true
		if isTailNeed {
			wrapperMessageLabelStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15).isActive = true
		} else {
			wrapperMessageLabelStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1).isActive = true
		}
		
		if reuseIdentifier == Constants.InputReuseIdentifier {
			setupInputMessageCell()
		} else {
			setupOutputMessageCell()
		}
	}
	
	private func setupInputMessageCell() {
		if #available(iOS 14.0, *) {
			wrapperMessageLabelStack.backgroundColor = Constants.inputMessageBackgroundColor
			if self.isTailNeed {
				tailImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
				tailImageView.tintColor = Constants.inputMessageBackgroundColor
				wrapperMessageLabelStack.addSubview(tailImageView)
				tailImageView.leftAnchor.constraint(equalTo: wrapperMessageLabelStack.leftAnchor, constant: -8).isActive = true
				tailImageView.bottomAnchor.constraint(equalTo: wrapperMessageLabelStack.bottomAnchor, constant: -4).isActive = true
			}
		} else {
			messageLabel.backgroundColor = Constants.inputMessageBackgroundColor
		}
		wrapperMessageLabelStack.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Constants.vStackUniversalOffset).isActive = true
	}
	
	private func setupOutputMessageCell() {
		if #available(iOS 14.0, *) {
			wrapperMessageLabelStack.backgroundColor = Constants.outputMessageBackgroundColor
			if self.isTailNeed {
				tailImageView.tintColor = Constants.outputMessageBackgroundColor
				wrapperMessageLabelStack.addSubview(tailImageView)
				tailImageView.rightAnchor.constraint(equalTo: wrapperMessageLabelStack.rightAnchor, constant: 8).isActive = true
				tailImageView.bottomAnchor.constraint(equalTo: wrapperMessageLabelStack.bottomAnchor, constant: -4).isActive = true
			}
		} else {
			messageLabel.backgroundColor = Constants.outputMessageBackgroundColor
		}
		wrapperMessageLabelStack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Constants.vStackUniversalOffset).isActive = true
	}
	
	private func getColorFromName(_ id: Int) -> UIColor {
		let component = abs(id % 7)
		var color = UIColor.black
		switch component {
		case 0: color = .orange
		case 1: color = .brown
		case 2: color = .blue
		case 3: color = .red
		case 4: color = .purple
		case 5: color = .green
		case 6: color = .cyan
		default: break
		}
		return color
	}
}
