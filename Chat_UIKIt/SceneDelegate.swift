//
//  SceneDelegate.swift
//  Chat_UIKIt
//
//  Created by Arshif on 17/08/2024.
//

import UIKit
import StreamChat

struct User {
    let id: String
    let name: String
    let token: String
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        let config = ChatClientConfig(apiKey: .init("y3c49p3sy7mu"))
        
        let user = User(id: "arshif1", name: "Chat User2", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYXJzaGlmMSJ9.1g8hcQ-x8GdYLxWa81rnWYLJxcOms2fq5u_7Tt3GfI4")

        
//        let user = User(id: "mohammed32", name: "Chat User1", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoibW9oYW1tZWQzMiJ9.WrDdRcMVfEcIJOyV-SgNb_qfrMOoQgboK9kedYfxjA0")

        let token = try! Token(rawValue: user.token)

        /// Step 1: create an instance of ChatClient and share it using the singleton
        ChatClient.shared = ChatClient(config: config)

        /// Step 2: connect to chat
        ChatClient.shared.connectUser(
            userInfo: UserInfo(
                id: user.id,
                name: user.name
            ),
            token: token
        )

        /// Step 3: create the ChannelList view controller
        let channelList = UserChannelList()
        let query = ChannelListQuery(filter: .containMembers(userIds: [user.id]))
        channelList.controller = ChatClient.shared.channelListController(query: query)

        /// Step 4: similar to embedding with a navigation controller using Storyboard
        window?.rootViewController = UINavigationController(rootViewController: channelList)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

