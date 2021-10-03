//
//  ConversationCell.swift
//  Chat
//
//  Created by Сергей on 03.10.2021.
//

import UIKit

protocol ConversationCellConfiguration: AnyObject {
	var name: String? { get set }
	var message: String? { get set }
	var date: Date? { get set }
	var online: Bool? { get set }
	var hasUnreadMessages: Bool? { get set }
}

class ConversationCell: UITableViewCell, ConversationCellConfiguration {
	
	var name: String? {
		willSet {
			nameLabel.text = newValue ?? ""
		}
	}
	
	var message: String? {
		willSet {
			messageLabel.text = (newValue ?? "") + "\n"
		}
	}
	
	var date: Date? {
		willSet {
			dateLabel.text = stringFromDate(newValue) + " >"
		}
	}
	
	var online: Bool? {
		willSet {
			guard let value = newValue else { return }
			userImageView.changeUserStatusTo(value ? .online : .offline)
		}
	}
	var hasUnreadMessages: Bool?
	
	private enum DateType {
		case correct
		case old
	}
	
	private let headerFontSize = 15.0
	private let bodyFontSize = 13.0
	
	private var nameLabel: UILabel!
	private var dateLabel: UILabel!
	private var messageLabel: UILabel!
	private var userImageView: UserImageView!
	private var contentVerticalStack: CustomStackView!
	private let imageHeight = 44.0
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	//MARK: - Private finctions
	private func setup() {
		nameLabel = UILabel()
		nameLabel.font = UIFont.boldSystemFont(ofSize: headerFontSize)
		
		dateLabel = UILabel()
		dateLabel.font = UIFont.systemFont(ofSize: bodyFontSize)
		dateLabel.textAlignment = .right
		
		let headerHorizontalStack = CustomStackView(axis: .horizontal, distribution: .fillProportionally)
		headerHorizontalStack.addArrangedSubview(nameLabel)
		headerHorizontalStack.addArrangedSubview(dateLabel)
		
		messageLabel = UILabel()
		messageLabel.numberOfLines = 2
		messageLabel.lineBreakMode = .byWordWrapping
		messageLabel.font = UIFont.systemFont(ofSize: bodyFontSize)
		
		contentVerticalStack = CustomStackView(axis: .vertical, distribution: .fillProportionally)
		contentVerticalStack.addArrangedSubview(headerHorizontalStack)
		contentVerticalStack.addArrangedSubview(messageLabel)
		contentVerticalStack.translatesAutoresizingMaskIntoConstraints = false
		
		userImageView = UserImageView(labelTitle: "TT", labelfontSize: imageHeight / 2)
		userImageView.layer.masksToBounds = false
		userImageView.layer.cornerRadius = imageHeight / 2
		
		self.contentView.addSubview(userImageView)
		self.contentView.addSubview(contentVerticalStack)
	
		userImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 20).isActive = true
		userImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
		userImageView.heightAnchor.constraint(equalToConstant: imageHeight).isActive = true
		userImageView.widthAnchor.constraint(equalToConstant: imageHeight).isActive = true
		
		contentVerticalStack.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true
		contentVerticalStack.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.9).isActive = true
		contentVerticalStack.leftAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 10).isActive = true
		contentVerticalStack.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -20).isActive = true
	
	}
	
	private func stringFromDate(_ date : Date?) -> String {
		guard let d = date else { return "" }
		let calendar = Calendar(identifier: .gregorian)
		let beginningDay = calendar.startOfDay(for: Date())
		let dateFormatter = DateFormatter()
		let dateFormat = (beginningDay < d) ? "HH:mm" : "dd/MM/YYYY"
		dateFormatter.dateFormat = dateFormat
		return dateFormatter.string(from: d)
	}

}
