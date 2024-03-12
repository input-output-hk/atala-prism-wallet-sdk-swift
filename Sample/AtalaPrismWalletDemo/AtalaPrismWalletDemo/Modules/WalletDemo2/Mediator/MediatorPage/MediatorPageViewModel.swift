import Combine
import Domain
import Foundation
import Pluto
import PrismAgent

final class MediatorViewModelImpl: MediatorPageViewModel {
    @Published var mediator: MediatorPageStateView.Mediator?
    @Published var agentRunning = false
    @Published var loading = false
    @Published var error: FancyToast?
    private let castor: Castor
    private let pluto: Pluto
    private let agent: PrismAgent

    init(castor: Castor, pluto: Pluto, agent: PrismAgent) {
        self.castor = castor
        self.pluto = pluto
        self.agent = agent

        bind()
    }

    func bind() {
        let agent = self.agent
        agentRunning = agent.state == .running
        return pluto
            .getAllMediators()
            .map {
                $0.first
            }.drop(while: {
                $0 == nil
            })
            .map {
                MediatorPageStateView.Mediator(
                    mediatorDID: $0!.mediatorDID.string,
                    routingDID: $0!.routingDID.string,
                    mediationAchieved: agent.state == .running
                )
            }
            .replaceError(with: nil)
            .assign(to: &$mediator)

        Task.detached { [weak self] in
            if
                let self,
                let mediator = try await self.pluto.getAllMediators().map({ $0.first}).first().await()
            {
                self.startAgent(mediatorDID: mediator.did.string)
            }
        }
    }

    func startAgent(mediatorDID: String) {
        let castor = self.castor
        Task.detached { [weak self] in
            do {
                let did = try castor.parseDID(str: mediatorDID)
                try await self?.agent.setupMediatorDID(did: did)
                try await self?.agent.start()
                self?.agent.startFetchingMessages()
                await MainActor.run { [weak self] in
                    self?.agentRunning = self?.agent.state == .running
                }
            } catch let error as LocalizedError {
                await MainActor.run { [weak self] in
                    self?.error = FancyToast(
                        type: .error,
                        title: error.localizedDescription,
                        message: error.errorDescription ?? ""
                    )
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.error = FancyToast(
                        type: .error,
                        title: error.localizedDescription,
                        message: ""
                    )
                }
            }
        }
    }

    func stopAgent() {
        Task.detached { [weak self] in
            do {
                try await self?.agent.stop()
                self?.agentRunning = self?.agent.state == .running
            } catch let error as LocalizedError {
                self?.error = FancyToast(
                    type: .error,
                    title: error.localizedDescription,
                    message: error.errorDescription ?? ""
                )
            } catch {
                self?.error = FancyToast(
                    type: .error,
                    title: error.localizedDescription,
                    message: ""
                )
            }
        }
    }
}
