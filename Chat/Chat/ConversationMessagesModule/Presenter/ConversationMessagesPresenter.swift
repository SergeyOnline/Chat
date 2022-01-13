//
//  ConversationMessagesPresenter.swift
//  Chat
//
//  Created by Сергей on 08.12.2021.
//

import UIKit
import Firebase
import CoreData

protocol IConversationMessagesView: AnyObject {
	func setInputTextFieldForAddAction(text: String)
	func presentImagePickerVC(viewController: UIViewController)
	func tableViewBeginUpdate()
	func tableViewEndUpdate()
	func tableViewInsertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
	func tableViewDeleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
	func tableViewReloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
	func setViewFrame(_ frame: CGRect)
	func scrollTableViewToEnd()
}

protocol IConversationMessagesPresenter: AnyObject {
	init(view: IConversationMessagesView, networkService: NetworkServiceProtocol, dataManager: DataManager, channel: DBChannel?)
	func addButtonAction()
	func sendButtonAction(forMessage message: String)
	func getChannelName() -> String?
	func getChannelTitle() -> String
	func getMessagesCount() -> Int?
	func getFetchedMessagesCount() -> Int?
	func getNumerOfSections() -> Int
	func getNumberOfRowsInSection(_ section: Int) -> Int
	func getCellIdForRowAt(indexPath: IndexPath) -> String
	func configureCell(_ cell: MessageCell, atIndexPath indexPath: IndexPath)
}

class ConversationMessagesPresenter: NSObject, IConversationMessagesPresenter {
	
	internal enum Constants {
		static let inputID = "input"
		static let outputID = "output"
		static let channelsDBCollection = "channels"
		static let messagesDBCollection = "messages"
	}
	
	private enum DateFormat {
		static let hourAndMinute = "HH:mm"
		static let dayAndMonth = "dd MMMM"
	}
	
	internal enum LocalizeKeys {
		static let messageInputFieldPlaceholder = "messageInputFieldPlaceholder"
		static let headerDateTitle = "headerDateTitle"
	}
	
	weak var view: IConversationMessagesView?
	let networkService: NetworkServiceProtocol
	let dataManager: DataManager
	let channel: DBChannel?
	
	internal let ownerID = UIDevice.current.identifierForVendor?.uuidString ?? ""
	private var ownerName = Owner().fullName
	internal var tailsArray: [Bool] = []
	
	private lazy var db = Firestore.firestore()
	private lazy var referenceChannel = db.collection(Constants.channelsDBCollection)
	private lazy var referenceMessages: CollectionReference = {
		guard let channelIdentifier = channel?.identifier else { fatalError() }
		return referenceChannel.document(channelIdentifier).collection(Constants.messagesDBCollection)
	}()
	
	private var listener: ListenerRegistration?
	internal lazy var fetchResultController: NSFetchedResultsController<DBMessage> = {
		let request: NSFetchRequest<DBMessage> = DBMessage.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "created", ascending: true)
		request.fetchBatchSize = 20
		request.sortDescriptors = [sortDescriptor]
		let predicate = NSPredicate(format: "channel.identifier == %@", (channel?.identifier ?? ""))
		request.predicate = predicate
		let controller = NSFetchedResultsController(fetchRequest: request,
													managedObjectContext: dataManager.persistentContainer.viewContext,
													sectionNameKeyPath: nil,
													cacheName: "messages")
		controller.delegate = self
		do {
			try controller.performFetch()
		} catch {
			fatalError("Failed to fetch entities: \(error)")
		}
		return controller
	}()
	
	required init(view: IConversationMessagesView, networkService: NetworkServiceProtocol, dataManager: DataManager, channel: DBChannel?) {
		self.view = view
		self.networkService = networkService
		self.channel = channel
		self.dataManager = dataManager
		super.init()
		setMessageListener()
		let userProfileHandler = GCDUserProfileInfoHandler()
		userProfileHandler.loadOwnerInfo { [weak self] in
			switch $0 {
			case .success(let owner): self?.ownerName = owner.fullName
			case .failure: self?.ownerName = Owner().fullName
			}
		}
	}
	
	func addButtonAction() {
		let imagePickerVC = ModuleAssembly.createImagePickerModule()
		if let controller = imagePickerVC as? ImagePickerViewController {
			controller.presenter?.completion = { imageAndLink in
				DispatchQueue.main.async {
					self.view?.setInputTextFieldForAddAction(text: imageAndLink.link)
				}
			}
		}
		view?.presentImagePickerVC(viewController: imagePickerVC)
	}
	
	func sendButtonAction(forMessage message: String) {
		let newMessage = ChannelMessage(content: message, created: Date(), senderId: ownerID, senderName: ownerName)
		referenceMessages.addDocument(data: newMessage.toDict)
	}
	
	func setMessageListener() {
		listener = referenceMessages.addSnapshotListener { [weak self] querySnapshot, error in
			if let error = error {
				print("Error getting documents: \(error)")
				return
			}
			guard let snapshot = querySnapshot else { return }
			guard let id = self?.channel?.identifier else { return }
			var messages: [DocumentChange] = []
			snapshot.documentChanges.forEach { message in
				if message.type == .added {
					messages.append(message)
				}
				// MARK: - modify message if needed
				// if message.type == .modified {}
				// MARK: - remove message if needed
				// if message.type == .removed {}
			}
			self?.dataManager.messagesService.saveMessages(messages, forChannelId: id, completion: {
				DispatchQueue.main.async {
					self?.view?.scrollTableViewToEnd()
				}
			})
		}
	}
	
	func getChannelName() -> String? {
		return channel?.name
	}
	
	func getChannelTitle() -> String {
		var result = ""
		guard let channelName = getChannelName() else { return result }
		if channelName.isEmpty { return result }
		let arr = channelName.components(separatedBy: " ")
		result.append(arr[0].first ?? " ")
		if arr.count > 1 {
			result.append(arr[1].first ?? " ")
		}
		return result.uppercased()
	}
	
	func getMessagesCount() -> Int? {
		guard let id = channel?.identifier else { return nil }
		let count = dataManager.messagesService.messagesCount(forChannel: id)
		return count < 1 ? nil : count
	}
	
	func getFetchedMessagesCount() -> Int? {
		return fetchResultController.fetchedObjects?.count
	}
	
	func getNumerOfSections() -> Int {
		fetchResultController.sections?.count ?? 0
	}
	
	func getNumberOfRowsInSection(_ section: Int) -> Int {
		guard let sections = self.fetchResultController.sections else {
			fatalError("No sections in fetchedResultsController")
		}
		let sectionInfo = sections[section]
		return sectionInfo.numberOfObjects
	}
	
	func getCellIdForRowAt(indexPath: IndexPath) -> String {
		let message = fetchResultController.object(at: indexPath)
		return (message.senderId != ownerID) ? Constants.inputID : Constants.outputID
	}
	
	func configureCell(_ cell: MessageCell, atIndexPath indexPath: IndexPath) {
		let index = indexPath.row
		guard let messages = fetchResultController.fetchedObjects else { return }
		tailsArray = [true]
		if messages.count >= 1 {
			for i in 1..<messages.count {
				if i == 0 {	continue }
				tailsArray.append(true)
				if messages[i].senderId == messages[i - 1].senderId {
					tailsArray[i - 1] = false
				}
			}
		}
		if index < tailsArray.count {
			cell.isTailNeed = tailsArray[index]
		}
		let message = fetchResultController.object(at: indexPath)
		let name = message.senderName ?? ""
		if index == 0 {
			cell.nameLabel.text = name.isEmpty ? "Unknown" : name
		} else {
			cell.nameLabel.text = (index < tailsArray.count && tailsArray[index - 1] == true) ? (name.isEmpty ? "Unknown" : name) : ""
		}
		cell.newDayLabel.text = calculateHeaderForMessagesOfOneDay(forCellIndex: indexPath)
		
		if let text = message.content {
			let textLower = text.lowercased()
			if (textLower.hasPrefix("https://") || textLower.hasPrefix("http://")) && (textLower.hasSuffix(".jpg") || textLower.hasSuffix(".png")) {
				if let url = URL(string: textLower), UIApplication.shared.canOpenURL(url) {
					networkService.getImageFromURL(url) { result in
						switch result {
						case .success(let image):
							DispatchQueue.main.async {
								cell.setupCellForImage(image)
							}
						case .failure: return
						}
					}
				}
			}
			cell.messageText = text
		} else {
			cell.messageText = ""
		}
		cell.date = stringFromDate(message.created ?? nil, whithFormat: DateFormat.hourAndMinute)
	}
	
	deinit {
		listener?.remove()
	}
	
	// MARK: - Private functions
	private func stringFromDate(_ date: Date?, whithFormat format: String) -> String {
		guard let d = date else { return "" }
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: d)
	}
	
	private func calculateHeaderForMessagesOfOneDay(forCellIndex indexPath: IndexPath) -> String {
		let message = fetchResultController.object(at: indexPath)
		let prevMessage: DBMessage
		if indexPath.row != 0 {
			let prevIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
			prevMessage = fetchResultController.object(at: prevIndexPath)
		} else {
			prevMessage = message
		}
		var result = ""
		let calendar = Calendar(identifier: .gregorian)
		if indexPath.row == 0 {
			if let currentMessageDate = message.created {
				if calendar.startOfDay(for: currentMessageDate) == calendar.startOfDay(for: Date()) {
					result = NSLocalizedString(LocalizeKeys.headerDateTitle, comment: "")
				} else {
					result = stringFromDate(currentMessageDate, whithFormat: DateFormat.dayAndMonth)
				}
			}
		} else {
			if let currentMessageDate = message.created, let previosMessageDate = prevMessage.created {
				let beginningDayCurent = calendar.startOfDay(for: currentMessageDate)
				let beginningDayPrevios = calendar.startOfDay(for: previosMessageDate)
				if beginningDayCurent != beginningDayPrevios {
					if beginningDayCurent == calendar.startOfDay(for: Date()) {
						result = NSLocalizedString(LocalizeKeys.headerDateTitle, comment: "")
					} else {
						result = stringFromDate(currentMessageDate, whithFormat: DateFormat.dayAndMonth)
					}
				}
			}
		}
		return result
	}
	
}

extension ConversationMessagesPresenter: NSFetchedResultsControllerDelegate {
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		view?.tableViewBeginUpdate()
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		view?.tableViewEndUpdate()
	}
	
	func controller(
		_ controller: NSFetchedResultsController<NSFetchRequestResult>,
		didChange anObject: Any,
		at indexPath: IndexPath?, for type: NSFetchedResultsChangeType,
		newIndexPath: IndexPath?
	) {
		switch type {
		case .insert:
			guard let newIndexPath = newIndexPath else { return	}
			view?.tableViewInsertRows(at: [newIndexPath], with: .none)
		case .delete:
			guard let indexPath = indexPath else { return	}
			view?.tableViewDeleteRows(at: [indexPath], with: .none)
		case .update:
			guard let indexPath = indexPath else { return }
			view?.tableViewReloadRows(at: [indexPath], with: .none)
		case .move:
			guard let indexPath = indexPath else { return }
			guard let newIndexPath = newIndexPath else { return	}
			view?.tableViewDeleteRows(at: [indexPath], with: .none)
			view?.tableViewInsertRows(at: [newIndexPath], with: .none)
		default: break
		}
	}
}
