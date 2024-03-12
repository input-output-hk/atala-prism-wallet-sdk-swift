import Domain

/**
 An enum representing a known error in a Prism agent API response.

 - Note: When an error occurs during an API request/response cycle, the server may return an error object in the response. This object may include an error code and an error message. If the error received conforms to the `KnownPrismError` protocol, it will be classified as a known error.

 - SeeAlso: `UnknownPrismError`, `KnownPrismError`
 */
public enum PrismAgentError: KnownPrismError {

    /// An error case representing that a DID key pair index could not be found.
    case cannotFindDIDKeyPairIndex

    /// An error case representing that an invitation is invalid.
    case invitationIsInvalidError

    /// An error case representing an unknown invitation type.
    case unknownInvitationTypeError

    /// An error case representing an invalid message type.
    case invalidMessageType(type: String, shouldBe: [String])

    /// An error case representing that no mediator is available.
    case noMediatorAvailableError

    /// An error case representing that a mediation request has failed.
    case mediationRequestFailedError(underlyingErrors: [Error]?)

    /// An error case representing that a key requires to conform to the Exportable protocol.
    case keyIsNotExportable

    /// An error case representing that the wallet was not initialized and a Link secret is not set yet.
    case noLinkSecretConfigured

    /// The error code returned by the server.
    public var code: Int {
        switch self {
        case .cannotFindDIDKeyPairIndex:
            return 111
        case .invitationIsInvalidError:
            return 112
        case .unknownInvitationTypeError:
            return 113
        case .invalidMessageType:
            return 114
        case .noMediatorAvailableError:
            return 115
        case .mediationRequestFailedError:
            return 116
        case .keyIsNotExportable:
            return 117
        case .noLinkSecretConfigured:
            return 118
        }
    }

    /**
     The error message returned by the server.

     - Note: For this enum, the error message is determined based on the specific error case that was encountered.

     - SeeAlso: `cannotFindDIDKeyPairIndex`, `invitationIsInvalidError`, `unknownInvitationTypeError`, `invalidMessageType`, `noMediatorAvailableError`, `mediationRequestFailedError`
     */
    public var message: String {
        switch self {
        case .cannotFindDIDKeyPairIndex:
            return "To sign with a DID a key pair needs to be registered, please register the key pair first/"
        case .invitationIsInvalidError:
            return "The system could not parse the invitation, the message/json are invalid"
        case .unknownInvitationTypeError:
            return "The type of the invitation is not supported."
        case let .invalidMessageType(type, shouldBe):
            return """
The following message \(type), does not represent the protocol \(shouldBe).
Also the message should have \"from\" and \"to\" fields
"""
        case .noMediatorAvailableError:
            return """
There is no mediator.
You need to provide a mediation handler and start the prism agent before doing some operations.
"""
        case .mediationRequestFailedError(let underlyningErrors):
            let errorsMessages = underlyningErrors
                .map { $0.map { $0.localizedDescription } }?
                .joined(separator: ", ")
            let message = errorsMessages.map { "Errors: " + $0 } ?? ""
            return "Something failed while trying to achieve mediation. \(message)"

        case .keyIsNotExportable:
            return "The key requires to conform to the Exportable protocol"

        case .noLinkSecretConfigured:
            return "The link secret was not initialized, please run start() once"
        }
    }
}

extension PrismAgentError: Equatable {
    public static func == (lhs: PrismAgentError, rhs: PrismAgentError) -> Bool {
        lhs.message == rhs.message
    }
}
