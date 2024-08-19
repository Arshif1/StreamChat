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
}
