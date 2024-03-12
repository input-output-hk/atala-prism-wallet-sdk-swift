import Combine
import Foundation
import PrismAgent

final class AddNewContactViewModelImpl: AddNewContactViewModel {
    @Published var flowStep: AddNewContactState.AddContacFlowStep
    @Published var code = ""
    @Published var dismiss = false
    @Published var dismissRoot = false
    @Published var loading = false
    @Published var contactInfo: AddNewContactState.Contact?

    private let agent: PrismAgent
    private var cancellables = Set<AnyCancellable>()

    init(
        token: String = "",
        agent: PrismAgent
    ) {
        code = token
        self.agent = agent
        flowStep = token.isEmpty ? .getCode : .checkDuplication
    }

    func isContactAlreadyAdded() {
        guard !loading else { return }
        loading = true
        Task { [weak self] in
            guard
                let self
            else { return }

            do {
                let connection = try agent.parseOOBInvitation(url: self.code)
                let didPairs = try await agent.getAllDIDPairs().first().await()

                await MainActor.run { [weak self] in
                    guard didPairs.first(where: { $0.other.string == connection.from }) == nil else {
                        self?.flowStep = .alreadyConnected
                        self?.loading = false
                        return
                    }

                    self?.contactInfo = .init(text: connection.from)
                    self?.flowStep = .confirmConnection
                    self?.loading = false
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.flowStep = .error(DisplayErrorState(error: error))
                    self?.loading = false
                }
            }
        }
    }

    func addContact() {
        guard contactInfo != nil, !loading else { return }
        loading = true
        Task { [weak self] in
            guard let self else { return }
            do {
                let connection = try agent.parseOOBInvitation(url: self.code)
                try await self.agent.acceptDIDCommInvitation(invitation: connection)
                await MainActor.run { [weak self] in
                    self?.dismiss = true
                    self?.dismissRoot = true
                    self?.loading = false
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.flowStep = .error(DisplayErrorState(error: error))
                    self?.loading = false
                }
            }
        }
    }
}
