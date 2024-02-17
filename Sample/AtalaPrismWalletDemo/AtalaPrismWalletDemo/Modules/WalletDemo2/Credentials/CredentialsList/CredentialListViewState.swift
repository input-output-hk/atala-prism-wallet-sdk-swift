struct CredentialListViewState {
    enum Requests: Identifiable, Hashable {
        case proposal(id: String, thid: String)
        case presentationRequest(id: String, thid: String)

        var id: String {
            switch self {
            case .proposal(let id, _):
                return id
            case .presentationRequest(let id, _):
                return id
            }
        }

        var textName: String {
            switch self {
            case .proposal:
                return "Credential Proposal"
            case .presentationRequest:
                return "Presentation Request"
            }
        }

        var thid: String {
            switch self {
            case .proposal(_, let thid):
                return thid
            case .presentationRequest(_, let thid):
                return thid
            }
        }
    }

    enum Responses: Identifiable, Hashable  {
        case credentialRequest(id: String)
        case presentation(id: String)

        var id: String {
            switch self {
            case .credentialRequest(let id):
                return id
            case .presentation(let id):
                return id
            }
        }
    }

    struct Credential: Hashable {
        let id: String
        let issuer: String
        let issuanceDate: String
        let type: String
    }
}
