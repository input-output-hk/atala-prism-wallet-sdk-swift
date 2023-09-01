import Combine
import Foundation
import PrismAgent

final class CredentialDetailViewModelImpl: CredentialDetailViewModel {
    @Published var schema = ""
    @Published var types = [String]()
    @Published var issued = ""
    @Published var dismiss = false
    @Published var error: Error?

    private let credentialId: String
    private let agent: PrismAgent
    private var cancellables = Set<AnyCancellable>()

    init(
        credentialId: String,
        agent: PrismAgent
    ) {
        self.credentialId = credentialId
        self.agent = agent

        bind()
    }

    private func bind() {
        agent.verifiableCredentials()
            .map { [weak self] in
                $0.first { $0.subject == self?.credentialId }
            }
            .replaceError(with: nil)
            .sink { [weak self] in
                guard
                    let credential = $0,
                    let schema = credential.properties["credentialSchema"] as? String
                else { return }
                self?.schema = schema
                self?.types = [""]
                self?.issued = ""
            }
            .store(in: &cancellables)
    }
}