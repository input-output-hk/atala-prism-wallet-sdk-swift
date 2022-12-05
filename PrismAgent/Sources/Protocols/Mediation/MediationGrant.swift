import Domain
import Foundation

struct MediationGrant {
    struct Body: Codable {
        let routingDid: [String]
    }

    let id: String
    let type = ProtocolTypes.didcommMediationGrant.rawValue
    let from: DID
    let to: DID
    let body: Body

    init(
        id: String = UUID().uuidString,
        from: DID,
        to: DID,
        body: Body
    ) {
        self.id = id
        self.from = from
        self.to = to
        self.body = body
    }

    init(fromMessage: Message) throws {
        guard
            fromMessage.piuri == ProtocolTypes.didcommMediationGrant.rawValue,
            let fromDID = fromMessage.from,
            let toDID = fromMessage.to
        else { throw PrismAgentError.invalidMediationGrantMessageError }
        self.init(
            id: fromMessage.id,
            from: fromDID,
            to: toDID,
            body: try JSONDecoder.didComm().decode(Body.self, from: fromMessage.body)
        )
    }
}
