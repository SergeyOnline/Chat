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

final class ConversationsListCell: UITableViewCell, ConversationCellConfiguration {
	
	private enum Constants {
		static let headerFontSize = 15.0
		static let bodyFontSize = 13.0
		static let imageHeight = 44.0
	}
	
	private enum LocalizeKeys {
		static let noMessages = "noMessages"
	}
	
	var name: String? {
		willSet {
			nameLabel.text = newValue ?? ""
			
			guard let value = newValue else { return }
			if value.isEmpty { return }
			let arr = value.components(separatedBy: " ")
			var initials = ""
			initials.append(arr[0].first ?? " ")
			if arr.count > 1 {
				initials.append(arr[1].first ?? " ")
			}
			userImageView.setInitials(initials: initials)
		}
	}
	
	var message: String? {
		willSet {
			if let value = newValue {
				messageLabel.font = UIFont.systemFont(ofSize: Constants.bodyFontSize)
				messageLabel.text = value + "\n"
			} else {
				messageLabel.font = UIFont.italicSystemFont(ofSize: Constants.bodyFontSize)
				messageLabel.text = NSLocalizedString(LocalizeKeys.noMessages, comment: "") + "\n"
			}
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
	var hasUnreadMessages: Bool? {
		willSet {
			guard let value = newValue else { return }
			
			if message != nil {
				if value {
					messageLabel.font = UIFont.boldSystemFont(ofSize: Constants.bodyFontSize + 2)
				} else {
					messageLabel.font = UIFont.systemFont(ofSize: Constants.bodyFontSize)
				}
			}
		}
	}
	
	// MARK: - UI
	private var nameLabel = UILabel()
	private var dateLabel = UILabel()
	private var messageLabel = UILabel()
	
	private var userImageView: UserImageView = {
		let imageView = UserImageView(labelTitle: "", labelfontSize: Constants.imageHeight / 2)
		return imageView
	}()
	
	private var contentVerticalStack: CustomStackView = {
		let stack = CustomStackView(axis: .vertical, distribution: .fillProportionally)
		return stack
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		contentView.backgroundColor = TableViewCellAppearance.backgroundColor.uiColor()
		nameLabel.textColor = TableViewCellAppearance.textColor.uiColor()
	}
	
	// MARK: - Private finctions
	private func setup() {
		
		contentView.backgroundColor = TableViewCellAppearance.backgroundColor.uiColor()
		nameLabel.font = UIFont.boldSystemFont(ofSize: Constants.headerFontSize)
		nameLabel.textColor = TableViewCellAppearance.textColor.uiColor()
		
		dateLabel.font = UIFont.systemFont(ofSize: Constants.bodyFontSize)
		dateLabel.textColor = .gray
		dateLabel.textAlignment = .right
		
		let headerHorizontalStack = CustomStackView(axis: .horizontal, distribution: .fillProportionally)
		headerHorizontalStack.addArrangedSubview(nameLabel)
		headerHorizontalStack.addArrangedSubview(dateLabel)
		
		messageLabel.numberOfLines = 2
		messageLabel.lineBreakMode = .byWordWrapping
		messageLabel.textColor = .gray
		
		contentVerticalStack.addArrangedSubview(headerHorizontalStack)
		contentVerticalStack.addArrangedSubview(messageLabel)
		contentVerticalStack.translatesAutoresizingMaskIntoConstraints = false
		
		userImageView.layer.masksToBounds = false
		userImageView.layer.cornerRadius = Constants.imageHeight / 2
		
		contentView.addSubview(userImageView)
		contentView.addSubview(contentVerticalStack)
	
		setupUserImageViewConstraints()
		setupContentVerticalStackConstraints()
		
	}
	
	private func setupUserImageViewConstraints() {
		userImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
		userImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
		userImageView.heightAnchor.constraint(equalToConstant: Constants.imageHeight).isActive = true
		userImageView.widthAnchor.constraint(equalToConstant: Constants.imageHeight).isActive = true
	}
	
	private func setupContentVerticalStackConstraints() {
		contentVerticalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
		contentVerticalStack.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.9).isActive = true
		contentVerticalStack.leftAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 10).isActive = true
		contentVerticalStack.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
	}
	
	private func stringFromDate(_ date: Date?) -> String {
		guard let d = date else { return "" }
		let calendar = Calendar(identifier: .gregorian)
		let beginningDay = calendar.startOfDay(for: Date())
		let dateFormatter = DateFormatter()
		let dateFormat = (beginningDay < d) ? "HH:mm" : "dd/MM/YYYY"
		dateFormatter.dateFormat = dateFormat
		return dateFormatter.string(from: d)
	}

}
