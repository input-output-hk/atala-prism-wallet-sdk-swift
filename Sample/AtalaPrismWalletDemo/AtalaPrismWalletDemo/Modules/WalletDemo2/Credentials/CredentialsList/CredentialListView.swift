import SwiftUI

protocol CredentialListViewModel: ObservableObject {
    var requests: [CredentialListViewState.Requests] { get }
    var responses: [CredentialListViewState.Responses] { get }
    var credentials: [CredentialListViewState.Credential] { get }
    var requestId: String? { get set }
    func acceptRequest(id: String, credentialId: String?)
    func rejectRequest(id: String)
}

protocol CredentialListRouter {
    associatedtype CredentialDetailV: View

    func routeToCredentialDetail(id: String) -> CredentialDetailV
}

struct CredentialListView<
    ViewModel: CredentialListViewModel,
        Router: CredentialListRouter
>: View {
    @StateObject var viewModel: ViewModel
    let router: Router

    @State var showCredentialList = false

    var body: some View {
        NavigationStack {
            List {
                Section("New Requests") {
                    ForEach(viewModel.requests) { flow in
                        VStack(alignment: .leading) {
                            Text(flow.textName)
                                .font(.headline)
                            Text(flow.thid)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            HStack {
                                Button(action: {
                                    switch flow {
                                    case .presentationRequest:
                                        viewModel.requestId = flow.id
                                        self.showCredentialList = true
                                    case .proposal:
                                        viewModel.acceptRequest(id: flow.id, credentialId: nil)
                                    }
                                }) {
                                   Image(systemName: "checkmark.circle.fill")
                                       .foregroundColor(.green)
                                       .font(.largeTitle)
                                }

                                Button(action: {
                                    viewModel.rejectRequest(id: flow.id)
                                }) {
                                   Image(systemName: "xmark.circle.fill")
                                       .foregroundColor(.red)
                                       .font(.largeTitle)
                                }
                            }
                        }
                    }
                }
                Section("Credentials") {
                    ForEach(viewModel.credentials, id: \.id) { credential in
                        NavigationLink(value: credential) {
                            VStack(alignment: .leading) {
//                                Text(credential.id)
//                                    .lineLimit(1)
//                                    .font(.headline)
//                                    .truncationMode(.middle)
                                Text(credential.issuer)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .font(.headline)
//                                    .foregroundColor(.secondary)
                                Text(credential.issuanceDate)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(credential.type)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                Section("Responses") {
                    ForEach(viewModel.responses) { flow in
                        switch flow {
                        case .credentialRequest(let id):
                            NavigationLink(value: flow) {
                                VStack(alignment: .leading) {
                                    Text("Credential Request")
                                        .font(.headline)
                                    Text(id)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        case .presentation(let id):
                            NavigationLink(value: flow) {
                                VStack(alignment: .leading) {
                                    Text("Presentation")
                                        .font(.headline)
                                    Text(id)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: CredentialListViewState.Credential.self) {
                router.routeToCredentialDetail(id: $0.id)
            }
            .navigationTitle("My Credentials")
            .sheet(isPresented: $showCredentialList) {
                CredentialSelectionListView<ViewModel>()
                    .environmentObject(viewModel)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

struct CredentialSelectionListView<ViewModel: CredentialListViewModel>: View {
    @EnvironmentObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            Section("Select Credential") {
                ForEach(viewModel.credentials, id: \.id) { credential in
                    Button(action: {
                        viewModel.acceptRequest(id: viewModel.requestId ?? "", credentialId: credential.id)
                        dismiss()
                    }) {
                        VStack(alignment: .leading) {
                            Text(credential.issuer)
                                .font(.headline)
                                .foregroundStyle(.black)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Text(credential.type)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
}
