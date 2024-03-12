import Combine
import PrismAgent
import Foundation

class BackupViewModelImpl: BackupViewModel {
    @Published var backupString = ""
    @Published var recoverWallet = ""
    @Published var dismiss = false
    private let agent: PrismAgent

    init(prismAgent: PrismAgent) {
        self.agent = prismAgent

        bind()
    }

    func bind() {
        Future {
            try await self.agent.backupWallet()
        }
        .replaceError(with: "")
        .receive(on: DispatchQueue.main)
        .assign(to: &$backupString)
    }

    func done() {
        guard !recoverWallet.isEmpty else { return }
        let jweString = recoverWallet
        let agent = agent
        Task.detached {
            do {
                try await agent.recoverWallet(encrypted: jweString)
                await MainActor.run { [weak self] in
                    self?.dismiss = true
                }
            } catch {
                print(error)
            }
        }
    }
}
