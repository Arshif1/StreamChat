//
//  DemoChannelList.swift
//  Chat_UIKIt
//
//  Created by Arshif on 17/08/2024.
//

import StreamChat
import StreamChatUI
import UIKit

class UserChannelList: ChatChannelListVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        router = ChatRouter(rootViewController: self)

        let buttonList = UIBarButtonItem(image: UIImage(systemName: "list.bullet.circle"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(tapActionList))
        
        let buttonAdd = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(tapActionAdd))
        
        self.navigationItem.rightBarButtonItems = [buttonAdd, buttonList]
    }
    
    @objc private func tapActionList() {
        let conroller = UINavigationController(rootViewController: AllChannelList())
        
        present(conroller, animated: true, completion: nil)
    }
    
    @objc private func tapActionAdd() {
        let conroller = UINavigationController(rootViewController: AddChannelVC())
        present(conroller, animated: true, completion: nil)
    }
    
}
