import Combine
import Domain
import Foundation
import EdgeAgent

class MediatorViewModelImpl: MediatorViewModel {
    @Published var routeToContactsList = false

    var agent: EdgeAgent?
    private var cancellables = Set<AnyCancellable>()

    func viewHasAppeared() {
        guard
            let didString = UserDefaults.standard.string(forKey: "mediatorDID"),
            let did = try? DID(string: didString)
        else { return }
        startAgentWithMediatorDID(did: did)
    }

    func initWithMediatorDID(mediatorDIDString: String) {
        guard
            let did = try? DID(string: mediatorDIDString)
        else { return }
        startAgentWithMediatorDID(did: did)
    }

    private func startAgentWithMediatorDID(did: DID) {
        Task { [weak self] in
            let agent = EdgeAgent(mediatorDID: did)
            try await agent.start()
            agent.startFetchingMessages()
            self?.agent = agent
            startWaitingForConnections()
            UserDefaults.standard.set(did.string, forKey: "mediatorDID")
            await MainActor.run { [weak self] in
                self?.routeToContactsList = true
            }
        }
    }

    private func startWaitingForConnections() {
        agent?.handleReceivedMessagesEvents()
            .drop {
                (try? ConnectionRequest(fromMessage: $0)) == nil
            }
            .flatMap { message in
                Future { [weak self] in
                    guard let req = try? ConnectionRequest(fromMessage: message) else { return message }
                    _ = try? await self?.agent?.sendMessage(message: ConnectionAccept(fromRequest: req).makeMessage())
                    return message
                }
                .flatMap {
                    self.createDIDPairOnConnection(message: $0)
                }
            }
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)

        agent?.handleReceivedMessagesEvents()
            .drop {
                (try? ConnectionAccept(fromMessage: $0)) == nil
            }
            .flatMap { message in
                self.createDIDPairOnConnection(message: message)
            }
            .sink(receiveCompletion: { _ in }, receiveValue: { })
            .store(in: &cancellables)
    }

    private func createDIDPairOnConnection(message: Message) -> Future<(), Error> {
        Future { [weak self] in
            guard
                let from = message.from,
                let to = message.to
            else { return }
            guard
                let (did, alias) = try await self?.agent?.getDIDInfo(did: to)
            else { return }
            try await self?.agent?.registerDIDPair(
                pair: DIDPair(
                    holder: did,
                    other: from,
                    name: alias
                ))
            return
        }
    }
}
