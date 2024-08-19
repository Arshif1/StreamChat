//
//  AllChannelList.swift
//  Chat_UIKIt
//
//  Created by Arshif on 19/08/2024.
//

import UIKit
import StreamChat
import StreamChatUI

class AllChannelList: UIViewController {
    
    private var availableChannelTypes: [ChannelType]  = [.livestream, .messaging, .team, .gaming, .commerce]
    
    private lazy var segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: availableChannelTypes.map(\.rawValue.capitalized))
        sc.selectedSegmentIndex = 0
        let font = UIFont.systemFont(ofSize: 9)
        sc.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        sc.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        return sc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    private func configure() {
        navigationItem.titleView = segmentedControl
        if let first = availableChannelTypes.first {
            segmentChanged(for: first)
        }
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        segmentChanged(for: availableChannelTypes[sender.selectedSegmentIndex])
    }
    
    private func segmentChanged(for channelType: ChannelType) {
        addChildVC(for: channelType)
    }
    
    private func addChildVC(for channelType: ChannelType) {
        let channelList = ChatChannelListWithStatusVC()
        let query = ChannelListQuery(filter: .equal("type", to: channelType.rawValue))
        channelList.controller = ChatClient.shared.channelListController(query: query)
        transitionToChildViewController(channelList)
    }
    
    private func createChildVC(_ childVC: UIViewController) {
        addChild(childVC)
        view.addSubview(childVC.view)
        childVC.view.frame = view.bounds
        childVC.didMove(toParent: self)
    }
    
    private func removeChildViewController(_ childVC: UIViewController) {
        childVC.willMove(toParent: nil)
        childVC.view.removeFromSuperview()
        childVC.removeFromParent()
    }
    
    private func transitionToChildViewController(_ childVC: UIViewController) {
        if let currentChildVC = children.first {
            removeChildViewController(currentChildVC)
        }
        createChildVC(childVC)
    }
}

class ChatChannelListWithStatusVC: ChatChannelListVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        router = ChatRouter(rootViewController: self)
    }
    
}
