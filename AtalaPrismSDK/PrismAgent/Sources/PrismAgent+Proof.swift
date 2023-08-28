import Core
import Combine
import Domain
import Foundation
import SwiftJWT

// MARK: Credentials proof functionalities
public extension PrismAgent {

    /// This function creates a Presentation from a request verfication.
    ///
    /// - Parameters:
    ///   - request: Request message received.
    ///   - credential: Verifiable Credential to present.
    /// - Returns: Presentation message prepared to send.
    /// - Throws: PrismAgentError, if there is a problem creating the presentation.
    func createPresentationForRequestProof(
        request: RequestPresentation,
        credential: Credential
    ) async throws -> Presentation {
        guard let proofableCredential = credential.proof else { throw UnknownError.somethingWentWrongError() }

        guard
            let subjectDIDString = credential.subject
        else {
            throw UnknownError.somethingWentWrongError()
        }
        
        let subjectDID = try DID(string: subjectDIDString)

        let didInfo = try await pluto
            .getDIDInfo(did: subjectDID)
            .first()
            .await()

        guard
            let storedPrivateKey = didInfo?.privateKeys.first
        else { throw PrismAgentError.cannotFindDIDKeyPairIndex }

        let privateKey = try await apollo.restorePrivateKey(
            identifier: storedPrivateKey.restorationIdentifier,
            data: storedPrivateKey.storableData
        )

        guard
            let exporting = privateKey.exporting
        else { throw PrismAgentError.cannotFindDIDKeyPairIndex }
        
        let presentationString = try proofableCredential.presentation(
            request: request.makeMessage(),
            options: [
                .exportableKey(exporting),
                .subjectDID(subjectDID)
            ]
        )
        
        guard let base64String = presentationString.data(using: .utf8)?.base64EncodedString() else {
            throw UnknownError.somethingWentWrongError()
        }
        return Presentation(
            body: .init(
                goalCode: request.body.goalCode,
                comment: request.body.comment
            ),
            attachments: [.init(
                mediaType: "prism/jwt",
                data: AttachmentBase64(base64: base64String)
            )],
            thid: request.thid,
            from: request.to,
            to: request.from
        )
    }
}
