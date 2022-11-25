import Domain
import Foundation

// ALL parameters are DIDCOMMV2 format and naming conventions and follows the protocol
// https://github.com/hyperledger/aries-rfcs/tree/main/features/0453-issue-credential-v2
public struct OfferCredential {
    struct Body: Codable, Equatable {
        let goalCode: String?
        let comment: String?
        let replacementId: String?
        let multipleAvailable: String?
        let credentialPreview: CredentialPreview
        let formats: [CredentialFormat]

        init(
            goalCode: String? = nil,
            comment: String? = nil,
            replacementId: String? = nil,
            multipleAvailable: String? = nil,
            credentialPreview: CredentialPreview,
            formats: [CredentialFormat]
        ) {
            self.goalCode = goalCode
            self.comment = comment
            self.replacementId = replacementId
            self.multipleAvailable = multipleAvailable
            self.credentialPreview = credentialPreview
            self.formats = formats
        }
    }

    public let id: String
    public let type = ProtocolTypes.didcommOfferCredential.rawValue
    let body: Body
    let attachments: [AttachmentDescriptor]
    public let thid: String?
    public let from: DID
    // swiftlint:disable identifier_name
    public let to: DID
    // swiftlint:enable identifier_name

    init(
        id: String = UUID().uuidString,
        body: Body,
        attachments: [AttachmentDescriptor],
        thid: String?,
        from: DID,
        // swiftlint:disable identifier_name
        to: DID
        // swiftlint:enable identifier_name
    ) {
        self.id = id
        self.body = body
        self.attachments = attachments
        self.thid = thid
        self.from = from
        self.to = to
    }

    public init(fromMessage: Message) throws {
        guard
            fromMessage.piuri == ProtocolTypes.didcommOfferCredential.rawValue,
            let fromDID = fromMessage.from,
            let toDID = fromMessage.to
        else { throw PrismAgentError.invalidOfferCredentialMessageError }

        let body = try JSONDecoder().decode(Body.self, from: fromMessage.body)
        self.init(
            id: fromMessage.id,
            body: body,
            attachments: fromMessage.attachments,
            thid: fromMessage.thid,
            from: fromDID,
            to: toDID
        )
    }

    public func makeMessage() throws -> Message {
        .init(
            id: id,
            piuri: type,
            from: from,
            to: to,
            body: try JSONEncoder().encode(body),
            attachments: attachments,
            thid: thid
        )
    }

    public static func makeOfferToProposedCredential(msg: Message) throws -> OfferCredential {
        let proposed = try ProposeCredential(fromMessage: msg)

        return OfferCredential(
            body: Body(
                goalCode: proposed.body.goalCode,
                comment: proposed.body.comment,
                credentialPreview: proposed.body.credentialPreview,
                formats: proposed.body.formats
            ),
            attachments: proposed.attachments,
            thid: msg.id,
            from: proposed.to,
            to: proposed.from)
    }

    static func build<T: Encodable>(
        fromDID: DID,
        toDID: DID,
        thid: String?,
        credentialPreview: CredentialPreview,
        credentials: [String: T] = [:]
    ) throws -> OfferCredential {
        let aux = try credentials.map { key, value in
            let attachment = try AttachmentDescriptor.build(payload: value)
            let format = CredentialFormat(attachId: attachment.id, format: key)
            return (format, attachment)
        }
        return OfferCredential(
            body: Body(
                credentialPreview: credentialPreview,
                formats: aux.map { $0.0 }
            ),
            attachments: aux.map { $0.1 },
            thid: thid,
            from: fromDID,
            to: toDID
        )
    }
}

extension OfferCredential: Equatable {
    public static func == (lhs: OfferCredential, rhs: OfferCredential) -> Bool {
        lhs.id == rhs.id &&
        lhs.type == rhs.type &&
        lhs.from == rhs.from &&
        lhs.to == rhs.to &&
        lhs.body == rhs.body
    }
}
