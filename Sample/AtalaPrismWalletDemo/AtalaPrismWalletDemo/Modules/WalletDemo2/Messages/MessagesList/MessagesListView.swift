import SwiftUI

protocol MessageListViewModel: ObservableObject {
    var messages: [MessagesListViewState.Message] { get }
}

protocol MessageListRouter {
    associatedtype MessageDetailV: View

    func routeToMessageDetail(messageId: String) -> MessageDetailV
}

struct MessagesListView<ViewModel: MessageListViewModel, Router: MessageListRouter>: View {
    @StateObject var viewModel: ViewModel
    let router: Router

    var body: some View {
        NavigationStack {
            List(viewModel.messages) { message in
                NavigationLink(value: message) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(message.title)
                            .font(.headline)
                            .fontWeight(.bold)
                        Text(message.did ?? "")
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .font(.subheadline)
                        Text(message.received ? "Received" : "Sent")
                            .foregroundColor(
                                message.received ?
                                Color.green.opacity(10)
                                : Color.blue.opacity(10)
                            )
                    }
                    .padding()
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationDestination(for: MessagesListViewState.Message.self) {
                router.routeToMessageDetail(messageId: $0.id)
            }
            .navigationTitle("My Messages")
        }
    }
}
