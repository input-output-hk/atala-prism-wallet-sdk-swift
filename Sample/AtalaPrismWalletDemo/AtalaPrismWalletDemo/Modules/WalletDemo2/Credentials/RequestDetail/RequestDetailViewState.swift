import Foundation

struct RequestDetailViewState {
    struct CredentialProposal {
        let thid: String
        let issuer: String
        let claims: [String: String]
    }

    struct PresentationRequest {
        struct CredentialPicker {
            let id: String
            let type: String
            let issuer: String
        }

        let thid: String
        let verifier: String
        let credentialPicker: [CredentialPicker]
    }

    enum RequestType {
        case credentialProposal(CredentialProposal)
        case presentationRequest(PresentationRequest)
    }
}
