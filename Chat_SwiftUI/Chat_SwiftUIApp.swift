//
//  Chat_SwiftUIApp.swift
//  Chat_SwiftUI
//
//  Created by Arshif on 17/08/2024.
//

import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct User {
    let id: String
    let name: String
    let token: String
}

@main
struct Chat_SwiftUIApp: App {
    
    @State var streamChat: StreamChat

    var chatClient: ChatClient = {
        //For the tutorial we use a hard coded api key and application group identifier
        var config = ChatClientConfig(apiKey: .init("y3c49p3sy7mu"))
        config.isLocalStorageEnabled = true
        config.applicationGroupIdentifier = "com.sample.Chat-SwiftUI"

        // The resulting config is passed into a new `ChatClient` instance.
        let client = ChatClient(config: config)
        return client
    }()
    
    init() {
        self.streamChat = StreamChat(chatClient: chatClient)
        let user = User(id: "arshif1", name: "Chat User2", token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYXJzaGlmMSJ9.1g8hcQ-x8GdYLxWa81rnWYLJxcOms2fq5u_7Tt3GfI4")
        connectUser(user: user)
    }
    
    var body: some Scene {
        WindowGroup {
            CustomChannelList()
        }
        
    }
    
    private func connectUser(user: User) {
        // This is a hardcoded token valid on Stream's tutorial environment.
        let token = try! Token(rawValue: user.token)
            
        // Call `connectUser` on our SDK to get started.
        chatClient.connectUser(
            userInfo: .init(
                id: user.id,
                name: user.name
            ),
            token: token
        ) { error in
            if let error = error {
                // Some very basic error handling only logging the error.
                log.error("connecting the user failed \(error)")
                return
            }
        }
    }
}
