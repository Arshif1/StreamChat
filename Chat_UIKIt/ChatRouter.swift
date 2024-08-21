//
//  ChatRouter.swift
//  Chat_UIKIt
//
//  Created by Arshif on 19/08/2024.
//

import UIKit
import StreamChat
import StreamChatUI

class ChatRouter: ChatChannelListRouter {
    
    override func didTapMoreButton(for cid: ChannelId) {
        let channelController = ChatClient.shared.channelController(for: cid)
        
        channelController.synchronize { error in
            guard error == nil else { return }
            
            if channelController.channel?.membership == nil {
                self.showAlert(message: "Join Channel") {
                    self.joinChannel(for: cid)
                }
            } else {
                self.showAlert(message: "Leave Channel") {
                    self.leaveChannel(for: cid)
                }
            }
        }
    }
    
    private func joinChannel(for cid: ChannelId) {
        guard let userID = ChatClient.shared.currentUserId else { return }
        let channelController =  ChatClient.shared.channelController(for: cid)
        channelController.synchronize { error in
            print("Error", error)
        }
        channelController.addMembers(userIds: [userID])
    }
    
    private func leaveChannel(for cid: ChannelId) {
        guard let userID = ChatClient.shared.currentUserId else { return }
        let channelController =  ChatClient.shared.channelController(for: cid)
        channelController.synchronize { error in
            print("Error", error)
        }
        channelController.removeMembers(userIds: [userID])
    }
    
    override func didTapDeleteButton(for cid: ChannelId) {
        let channelController = ChatClient.shared.channelController(for: cid)
        channelController.deleteChannel { error in
            print("Error", error)
        }
    }
    
    func showAlert(message: String, action: @escaping () -> Void) {
        // Create the alert controller
        let alert = UIAlertController(title: "",
                                      message: message,
                                      preferredStyle: .alert)
        
        // Add an action (button) to the alert
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            action()
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        rootViewController.present(alert, animated: true)
        
    }
    
    override func showChannel(for cid: ChannelId, at messageId: MessageId?) {
        let vc = CustomChatChannelVC()
        
        if let messageId = messageId {
            vc.channelController = rootViewController.controller.client.channelController(
                for: ChannelQuery(
                    cid: cid,
                    pageSize: .messagesPageSize,
                    paginationParameter: .around(messageId)
                ),
                channelListQuery: rootViewController.controller.query
            )
        } else {
            vc.channelController = rootViewController.controller.client.channelController(
                for: cid,
                channelListQuery: rootViewController.controller.query
            )
        }
        
        if let navigationVC = rootViewController.navigationController {
            navigationVC.show(vc, sender: self)
        }
    }
    
}


class CustomChatChannelVC: ChatChannelVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageComposerVC.composerView.leadingContainer.addArrangedSubviews([
            button()
        ])
    }
    
    private func button() -> UIView {
        let button = PayButton()
        button.addTarget(self, action: #selector(tapActionPayButton), for: .touchUpInside)
        return button
    }
    
    @objc private func tapActionPayButton(sender: UIButton) {
        let amountInputViewController = AmountInputViewController()
        amountInputViewController.channelId = channelController.cid
        amountInputViewController.amountInputClosure = { message in
            self.messageComposerVC.createNewMessage(text: message)
            amountInputViewController.dismiss(animated: true)
        }
        present(UINavigationController(rootViewController: amountInputViewController), animated: true)
    }
}

class PayButton: _Button, AppearanceProvider {
    
    override func setUpAppearance() {
        super.setUpAppearance()
        
        guard let payIcon = UIImage(systemName: "dollarsign")?
            .tinted(with: appearance.colorPalette.inactiveTint)
        else { return }
        
        setImage(payIcon, for: .normal)
    }
}


extension UIImage {
    func tinted(with fillColor: UIColor) -> UIImage? {
        let image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        fillColor.set()
        image.draw(in: CGRect(origin: .zero, size: size))

        guard let imageColored = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }

        UIGraphicsEndImageContext()
        return imageColored
    }
}


class AmountInputViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AppearanceProvider {
    
    var amountInputClosure: ((String) -> Void)?
    
    private lazy var amountInputView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = appearance.colorPalette.inactiveTint.withAlphaComponent(0.25)
        return view
    }()
    
    private let textfield: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.keyboardType = .decimalPad
        tf.textAlignment = .left
        tf.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        tf.placeholder = "Enter Amount"
        return tf
    }()
    
    private lazy var tableView: UITableView = {
        let tbl = UITableView()
        tbl.delegate = self
        tbl.dataSource = self
        tbl.translatesAutoresizingMaskIntoConstraints = false
        tbl.backgroundColor = .white
        return tbl
    }()
    
    private let labelCurrency: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        lbl.text = "$"
        return lbl
    }()
    
    private lazy var buttonSubmit: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Submit", for: .normal)
        button.addTarget(self, action: #selector(tapActionButtonSubmit), for: .touchUpInside)
        button.backgroundColor = appearance.colorPalette.inactiveTint
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return button
    }()
    
    @objc private func tapActionButtonSubmit() {
        guard let text = textfield.text, let _ = Double(text) else { return }
        let amountString = distributedAmountDictionary.map {
            let nameWithoutSpaces = $0.key.name!.replacingOccurrences(of: " ", with: "").lowercased()
            return ($0.key.name!) + " $ \($0.value)" + " https://www.payamount.com/\(nameWithoutSpaces)/\($0.value)"
        }.joined(separator: "\n")
        
        amountInputClosure?(amountString)
    }
    
    private var members: LazyCachedMapCollection<ChatChannelMember>? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var channelId: ChannelId?
    
    private var client: ChatClient {
        ChatClient.shared
    }
    
    private var distributedAmountDictionary: [ChatChannelMember: Double] = [:]
    
    @objc func textFieldDidChange(_ textfield: UITextField) {
        calculateDistribution()
    }
    
    private func calculateDistribution() {
        distributedAmountDictionary = [:]
        let numberofPeoples = selectedMembers.count
        guard let text = textfield.text, let totalAmount = Double(text), numberofPeoples > 0 else {
            tableView.reloadData()
            return
        }
        
        let baseAmount = totalAmount / Double(numberofPeoples)
        
        let baseAmountRounded = (baseAmount * 100).rounded() / 100.0
        
        let distributedAmount = baseAmountRounded * Double(numberofPeoples)
        
        let remainder = totalAmount - distributedAmount
        
        selectedMembers.forEach { member in
            distributedAmountDictionary[member] = baseAmountRounded
        }
        
        if remainder > 0, let member = selectedMembers.randomElement() {
            distributedAmountDictionary[member] = baseAmountRounded + remainder
        }
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Amount"
        view.addSubview(amountInputView)
        view.addSubview(tableView)
        view.addSubview(buttonSubmit)
        
        amountInputView.addSubview(textfield)
        amountInputView.addSubview(labelCurrency)
        
        
        
        textfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        NSLayoutConstraint.activate([
            amountInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            amountInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            amountInputView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            amountInputView.heightAnchor.constraint(equalToConstant: 170),
                        
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: amountInputView.bottomAnchor),
            buttonSubmit.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 5),
            
            buttonSubmit.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -2),
            buttonSubmit.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonSubmit.heightAnchor.constraint(equalToConstant: 50),
            buttonSubmit.widthAnchor.constraint(equalToConstant: 140),
            
            textfield.centerYAnchor.constraint(equalTo: amountInputView.centerYAnchor),
            textfield.leadingAnchor.constraint(equalTo: labelCurrency.trailingAnchor, constant: 16),
            textfield.heightAnchor.constraint(equalToConstant: 50),
            
            labelCurrency.centerYAnchor.constraint(equalTo: textfield.centerYAnchor),
            labelCurrency.trailingAnchor.constraint(equalTo: textfield.leadingAnchor, constant: -3),
            labelCurrency.leadingAnchor.constraint(equalTo: amountInputView.leadingAnchor, constant: 16)
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        guard let channelId else { return }
        fetchUsersInChannel(channelId: channelId)
    }
    
    func fetchUsersInChannel(channelId: ChannelId) {
        
        let memberListController = client.memberListController(query: .init(cid: channelId))
        memberListController.synchronize() { error in
            guard error == nil else {
                self.members = nil
                return
            }
            self.members = memberListController.members
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        members?.count ?? 0
    }
    
    private var selectedMembers = Set<ChatChannelMember>()
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let member = members![indexPath.row]
        cell.accessoryType = selectedMembers.contains(member) ? .checkmark : .none
        var amountText = member.name ?? ""
        
        if let amount = distributedAmountDictionary[member], amount > 0 {
            amountText += " $ \(amount)"
        } else {
            amountText += " "
        }
        
        cell.textLabel?.text = amountText
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let member = members![indexPath.row]
        
        if selectedMembers.contains(member) {
            selectedMembers.remove(member)
        } else {
            selectedMembers.insert(member)
        }
        
        calculateDistribution()
    }
}
