import Combine
import Domain
import Foundation
import PrismAgent

final class CredentialListViewModelImpl: CredentialListViewModel {
    @Published var requests = [CredentialListViewState.Requests]()
    @Published var responses = [CredentialListViewState.Responses]()
    @Published var credentials = [CredentialListViewState.Credential]()
    @Published var requestId: String? = nil

    private let agent: PrismAgent
    private let pluto: Pluto

    init(
        agent: PrismAgent,
        pluto: Pluto
    ) {
        self.agent = agent
        self.pluto = pluto
        bind()
    }

    private func bind() {
        self.agent
            .verifiableCredentials()
            .map {
                $0.map {
                    CredentialListViewState.Credential(
                        id: $0.id,
                        issuer: $0.issuer,
                        issuanceDate: $0.storable?.queryCredentialCreated?.formatted() ?? "",
                        type: $0.credentialType
                    )
                }
            }
            .replaceError(with: [])
            .assign(to: &$credentials)

        finalThreadFlowRequests()
        finalThreadFlowResponses()
    }

    private func finalThreadFlowRequests() {
        pluto.getAllMessages()
            .map {
                getRequests(messages: $0)
            }
            .replaceError(with: [])
            .assign(to: &$requests)
    }

    private func finalThreadFlowResponses() {
        pluto.getAllMessages()
            .map {
                getResponses(messages: $0)
            }
            .replaceError(with: [])
            .assign(to: &$responses)
    }

    func acceptRequest(id: String, credentialId: String?) {
        Task.detached { [weak self] in
            do {
                guard
                    let self,
                    let message = try await self.pluto.getMessage(id: id).first().await()
                else {
                    return
                }
                switch message.piuri {
                case ProtocolTypes.didcommOfferCredential3_0.rawValue:
                    let newPrismDID = try await self.agent.createNewPrismDID()
                    guard let requestCredential = try await self.agent.prepareRequestCredentialWithIssuer(
                        did: newPrismDID,
                        offer: try OfferCredential3_0(fromMessage: message)
                    ) else { throw UnknownError.somethingWentWrongError() }
                    _ = try await self.agent.sendMessage(message: try requestCredential.makeMessage())

                case ProtocolTypes.didcommRequestPresentation.rawValue:
                    let credential = try await self.agent.verifiableCredentials()
                        .map { $0.first { $0.id == credentialId } }
                        .first()
                        .await()
                    guard let credential else {
                        throw UnknownError.somethingWentWrongError()
                    }
                    let presentation = try await self.agent.createPresentationForRequestProof(
                        request: try RequestPresentation(fromMessage: message),
                        credential: credential
                    )
                    _ = try await self.agent.sendMessage(message: try presentation.makeMessage())
                default:
                    throw UnknownError.somethingWentWrongError(customMessage: nil, underlyingErrors: nil)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func rejectRequest(id: String) {
    }
}

private func getRequests(messages: [Message]) -> [CredentialListViewState.Requests] {
    let groupedByThreadId = Dictionary(grouping: messages) { $0.thid ?? "" }
    let sortedValues = groupedByThreadId.mapValues { $0.sorted(by: { $0.createdTime < $1.createdTime }) }
    return sortedValues.compactMap { dicRow -> CredentialListViewState.Requests? in
        guard let last = dicRow.value.last else {
            return nil
        }
        switch last.piuri {
        case "https://didcomm.org/issue-credential/3.0/offer-credential":
//            print(try! (last.attachments.first!.data as! AttachmentJsonData).data.tryToString())
            return CredentialListViewState.Requests.proposal(id: last.id, thid: dicRow.key)
        case "https://didcomm.atalaprism.io/present-proof/3.0/request-presentation":
//            print(try! (last.attachments.first!.data as! AttachmentJsonData).data.tryToString())
            return CredentialListViewState.Requests.presentationRequest(id: last.id, thid: dicRow.key)
        default:
            return nil
        }
    }
}

private func getResponses(messages: [Message]) -> [CredentialListViewState.Responses] {
    let groupedByThreadId = Dictionary(grouping: messages) { $0.thid ?? "" }
    let sortedValues = groupedByThreadId.mapValues { $0.sorted(by: { $0.createdTime < $1.createdTime }) }
    return sortedValues.compactMap { dicRow -> CredentialListViewState.Responses? in
        guard let last = dicRow.value.last else {
            return nil
        }
        switch last.piuri {
        case "https://didcomm.org/issue-credential/3.0/request-credential":
            return CredentialListViewState.Responses.credentialRequest(id: dicRow.key)
        case "https://didcomm.atalaprism.io/present-proof/3.0/presentation":
            return CredentialListViewState.Responses.presentation(id: dicRow.key)
        default:
            return nil
        }
    }
}
