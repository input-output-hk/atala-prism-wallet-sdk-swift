import SwiftUI

protocol ConnectionsListViewModel: ObservableObject {
    var connections: [ConnectionsViewState.Connection] { get }
    var error: FancyToast? { get set }

    func addConnection(invitation: String, alias: String)
}

protocol ConnectionsListRouter {
    associatedtype AddNewConnectionV: View
    func routeToAddNewConnection() -> AddNewConnectionV
}

struct ConnectionsListView<ViewModel: ConnectionsListViewModel, Router: ConnectionsListRouter>: View {
    let router: Router
    @StateObject var viewModel: ViewModel
    @State var showAddConnection = false
    @State var aliasInput = ""
    @State var newConnectionInput = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.connections) { connection in
                    VStack(spacing: 8) {
                        if let alias = connection.alias, !alias.isEmpty {
                            Text(alias)
                        }
                        HStack {
                            Text("Host: ")
                            Text(connection.hostDID)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }

                        HStack {
                            Text("Recipient: ")
                            Text(connection.recipientDID)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                    }
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddConnection = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            })
            .clearFullScreenCover(isPresented: $showAddConnection) {
                router.routeToAddNewConnection()
            }
            .navigationTitle("My Connections")
        }
    }
}
