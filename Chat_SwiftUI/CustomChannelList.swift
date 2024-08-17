import SwiftUI
import StreamChat
import StreamChatSwiftUI

struct CustomChannelList: View {
    
    @StateObject private var viewModel: ChatChannelListViewModel
    @StateObject private var channelHeaderLoader = ChannelHeaderLoader()
    
    public init(
        channelListController: ChatChannelListController? = nil
    ) {
        let channelListVM = ViewModelsFactory.makeChannelListViewModel(
            channelListController: channelListController,
            selectedChannelId: nil
        )
        _viewModel = StateObject(
            wrappedValue: channelListVM
        )
    }
    
    let factory = CustomViewFactory()
    
    var body: some View {
        NavigationView {
            ChannelList(
                factory: factory,
                channels: viewModel.channels,
                selectedChannel: $viewModel.selectedChannel,
                swipedChannelId: $viewModel.swipedChannelId,
                onItemTap: { channel in
                    viewModel.selectedChannel = channel.channelSelectionInfo
                },
                onItemAppear: { index in
                    viewModel.checkForChannels(index: index)
                },
                channelDestination: CustomViewFactory.shared.makeChannelDestination()
            )
            .toolbar {
                DefaultChatChannelListHeader(title: "Stream Tutorial")
            }
        }
    }
    
    class CustomViewFactory: ViewFactory {
        @Injected(\.chatClient) var chatClient: ChatClient
        
        static let shared = CustomViewFactory()
        
        func makeChannelDestination() -> (ChannelSelectionInfo) -> CustomChannelView {
            { channelInfo in
                CustomChannelView(channelId: channelInfo.channel.cid)
            }
        }
    }
}
