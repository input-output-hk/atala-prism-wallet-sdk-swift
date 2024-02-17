import SwiftUI

protocol CredentialDetailViewModel: ObservableObject {
    var credential: CredentialDetailViewState { get }
}

struct CredentialDetailView<ViewModel: CredentialDetailViewModel>: View {
    
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Issuer: ")
                        .font(.title2)
                    Text(viewModel.credential.issuer)
                        .lineLimit(3)
                        .truncationMode(.middle)
                }

                if let id = viewModel.credential.credentialDefinitionId {
                    HStack {
                        Text("Credential Definition ID: ")
                            .font(.title2)
                        Text(id)
                            .lineLimit(3)
                            .truncationMode(.middle)
                    }
                }
                if let id = viewModel.credential.schemaId {
                    HStack {
                        Text("Schema ID:")
                            .font(.title2)
                        Text(id)
                            .lineLimit(3)
                            .truncationMode(.middle)
                    }
                }
            }
            .padding()

            List {
                Section("Claims") {
                    ForEach(viewModel.credential.claims.sorted(by: >), id: \.key) { key, value in
                        Text("\(key): \(value)")
                            .lineLimit(3)
                            .truncationMode(.middle)
                    }
                }
            }
        }
    }
}

private class MockViewModel: CredentialDetailViewModel {
    var credential: CredentialDetailViewState = .init(
        issuer: "did:test:adasdasd",
        claims: [
            "test1": "test",
            "test2": "test"
        ],
        credentialDefinitionId: "testId1",
        schemaId: "testId2"
    )
}

#Preview {
    CredentialDetailView(viewModel: MockViewModel())
}
