import AnoncredsSwift
import Core
import Domain
import Foundation
import JSONWebAlgorithms
import JSONWebToken
import JSONWebSignature
import Sextant
import JSONSchema

extension PolluxImpl {

    private enum ValidJsonTypeFilter: String {
        case string
        case number
        case boolean
    }

    public func verifyPresentation(message: Message, options: [CredentialOperationsOptions]) async throws -> Bool {
        guard 
            let attachment = message.attachments.first,
            let requestId = message.thid
        else {
            throw PolluxError.couldNotFindPresentationInAttachments
        }

        let jsonData: Data
        switch attachment.data {
        case let attchedData as AttachmentBase64:
            guard let decoded = Data(fromBase64URL: attchedData.base64) else {
                throw CommonError.invalidCoding(message: "Invalid base64 url attachment")
            }
            jsonData = decoded
        case let attchedData as AttachmentJsonData:
            jsonData = attchedData.data
        default:
            throw PolluxError.invalidAttachmentType(supportedTypes: ["Json", "Base64"])
        }

        switch attachment.format {
        case "dif/presentation-exchange/submission@v1.0":
            return try await verifyPresentationSubmission(json: jsonData, requestId: requestId)
        case "anoncreds/proof@v1.0":
            return try await verifyAnoncreds(
                presentation: jsonData,
                requestId: requestId,
                options: options
            )
        default:
            throw PolluxError.unsupportedAttachmentFormat(attachment.format)
        }
    }

    private func verifyPresentationSubmission(json: Data, requestId: String) async throws -> Bool {
        let presentationContainer = try JSONDecoder.didComm().decode(PresentationContainer.self, from: json)
        let presentationRequest = try await getDefinition(id: requestId)
        guard let submission = presentationContainer.presentationSubmission else {
            throw PolluxError.presentationSubmissionNotAvailable
        }
        let credentials = try getCredentialJWT(submission: submission, presentationData: json)

        try VerifyPresentationSubmission.verifyPresentationSubmissionClaims(
            request: presentationRequest.presentationDefinition,
            credentials: try credentials.map {
                try JWT.getPayload(jwtString: $0)
            }
        )

        try await verifyJWTs(credentials: credentials)
        return true
    }

    private func getCredentialJWT(submission: PresentationSubmission, presentationData: Data) throws -> [String] {
        return submission.descriptorMap
            .filter({ $0.format == "jwt" || $0.format == "jwt_vc" || $0.format == "jwt_vp" })
            .compactMap { try? processJWTPath(descriptor: $0, presentationData: presentationData) }
    }

    private func processJWTPath(descriptor: PresentationSubmission.Descriptor, presentationData: Data) throws -> String {
        guard descriptor.format == "jwt" || descriptor.format == "jwt_vc" || descriptor.format == "jwt_vp" else {
            throw UnknownError.somethingWentWrongError(
                customMessage: "This should not happen since its filtered before",
                underlyingErrors: nil
            )
        }

        guard
            let jwts = presentationData.query(string: descriptor.path)
        else {
            throw PolluxError.credentialPathInvalid(path: descriptor.path)
        }

        guard let nestedDescriptor = descriptor.pathNested else {
            return jwts
        }
        let nestedPayload: Data = try JWT.getPayload(jwtString: jwts)
        return try processJWTPath(descriptor: nestedDescriptor, presentationData: nestedPayload)
    }

    private func verifyJWTs(credentials: [String]) async throws {
        var errors = [Error]()
        await credentials
            .asyncForEach {
                do {
                    try await verifyJWT(jwtString: $0)
                } catch {
                    errors.append(error)
                }
            }
        guard errors.isEmpty else {
            throw PolluxError.cannotVerifyPresentationInputs(errors: errors)
        }
    }

    private func verifyJWT(jwtString: String) async throws -> Bool {
        try await verifyJWTCredentialRevocation(jwtString: jwtString)
        let payload: DefaultJWTClaimsImpl = try JWT.getPayload(jwtString: jwtString)
        guard let issuer = payload.iss else {
            throw PolluxError.requiresThatIssuerExistsAndIsAPrismDID
        }

        let issuerDID = try DID(string: issuer)
        let issuerKeys = try await castor.getDIDPublicKeys(did: issuerDID)
        
        ES256KVerifier.bouncyCastleFailSafe = true

        let validations = issuerKeys
            .compactMap(\.exporting)
            .compactMap {
                try? JWT.verify(jwtString: jwtString, senderKey: $0.jwk.toJoseJWK())
            }
        ES256KVerifier.bouncyCastleFailSafe = false
        return !validations.isEmpty
    }

    private func verifyJWTCredentialRevocation(jwtString: String) async throws {
        guard let credential = try? JWTCredential(data: jwtString.tryToData()) else {
            return
        }
        let isRevoked = try await credential.isRevoked
        let isSuspended = try await credential.isSuspended
        guard !isRevoked else {
            throw PolluxError.credentialIsRevoked(jwtString: jwtString)
        }
        guard !isSuspended else {
            throw PolluxError.credentialIsSuspended(jwtString: jwtString)
        }
    }

    private func getDefinition(id: String) async throws -> PresentationExchangeRequest {
        guard 
            let request = try await pluto.getMessage(id: id).first().await(),
            let attachmentData = request.attachments.first?.data
        else {
            throw PolluxError.couldNotFindPresentationRequest(id: id)
        }

        let json: Data
        switch attachmentData {
        case let jsonData as AttachmentJsonData:
            json = jsonData.data
        case let base64Data as AttachmentBase64:
            json = try base64Data.decoded()
        default:
            throw PolluxError.invalidAttachmentType(supportedTypes: ["base64", "json"])
        }

        return try JSONDecoder.didComm().decode(PresentationExchangeRequest.self, from: json)
    }

    private func verifyAnoncreds(
        presentation: Data,
        requestId: String,
        options: [CredentialOperationsOptions]
    ) async throws -> Bool {
        let anonPresentation = try AnoncredsSwift.Presentation(jsonString: presentation.tryToString())
        let requestPresentation = try await getAnoncredsRequest(id: requestId)

        let internalPresentation = try JSONDecoder.didComm().decode(AnonPresentation.self, from: presentation)
        let schemaIds = internalPresentation.identifiers.map(\.schemaId)
        let credentialDefinitionsIds = internalPresentation.identifiers.map(\.credDefId)
        let anonSchemas = try await getSchemas(ids: schemaIds, options: options)
            .mapValues { try JSONDecoder.didComm().decode(AnonCredentialSchema.self, from: $0) }
            .mapValues {
                Schema(
                    name: $0.name,
                    version: $0.version,
                    attrNames: $0.attrNames.map { AttributeNames($0) } ?? AttributeNames(),
                    issuerId: $0.issuerId
                )
            }
        let anonCredentialDefinitions = try await getCredentialDefinitions(
            ids: credentialDefinitionsIds,
            options: options
        ).mapValues { try AnoncredsSwift.CredentialDefinition(jsonString: $0.tryToString()) }

        return try Verifier().verifyPresentation(
            presentation: anonPresentation,
            presentationRequest: requestPresentation,
            schemas: anonSchemas,
            credentialDefinitions: anonCredentialDefinitions
        )
    }

    private func getAnoncredsRequest(id: String) async throws -> AnoncredsSwift.PresentationRequest {
        guard
            let request = try await pluto.getMessage(id: id).first().await(),
            let attachmentData = request.attachments.first?.data
        else {
            throw PolluxError.couldNotFindPresentationRequest(id: id)
        }

        let json: Data
        switch attachmentData {
        case let jsonData as AttachmentJsonData:
            json = jsonData.data
        case let base64Data as AttachmentBase64:
            guard let data = try Data(fromBase64URL: base64Data.base64.tryToData()) else {
                throw CommonError.invalidCoding(message: "Could not decode base64 message attchment")
            }
            json = data
        default:
            throw PolluxError.invalidAttachmentType(supportedTypes: [])
        }

        return try PresentationRequest(jsonString: json.tryToString())
    }

    private func getSchemas(ids: [String], options: [CredentialOperationsOptions]) async throws -> [String: Data] {
        if
            let schemasOption = options.first(where: {
                if case .schema = $0 { return true }
                return false
            }),
            case let CredentialOperationsOptions.schema(id, json) = schemasOption
        {
            return try [id: json.tryToData()]
        }

        guard
            let schemaDownloaderOption = options.first(where: {
                if case .schemaDownloader = $0 { return true }
                return false
            }),
            case let CredentialOperationsOptions.schemaDownloader(downloader) = schemaDownloaderOption
        else {
            throw PolluxError.missingAndIsRequiredForOperation(type: "schemaDownloader")
        }
        let schemas = try await ids.asyncMap { ($0, try await downloader.downloadFromEndpoint(urlOrDID: $0)) }
        return schemas.reduce( [String: Data]()) { partialResult, schemas in
            var dic = partialResult
            dic[schemas.0] = schemas.1
            return dic
        }
    }

    private func getCredentialDefinitions(
        ids: [String],
        options: [CredentialOperationsOptions]
    ) async throws -> [String: Data] {
        if
            let credentialDefinitionsOption = options.first(where: {
                if case .credentialDefinition = $0 { return true }
                return false
            }),
            case let CredentialOperationsOptions.credentialDefinition(id, json) = credentialDefinitionsOption
        {
            return try [id: json.tryToData()]
        }

        guard
            let credentialDefinitionsDownloaderOption = options.first(where: {
                if case .credentialDefinitionDownloader = $0 { return true }
                return false
            }),
            case let CredentialOperationsOptions.credentialDefinitionDownloader(downloader) = credentialDefinitionsDownloaderOption
        else {
            throw PolluxError.missingAndIsRequiredForOperation(type: "credentialDefinitionDownloader")
        }
        let definitions = try await ids.asyncMap { ($0, try await downloader.downloadFromEndpoint(urlOrDID: $0)) }
        return definitions.reduce( [String: Data]()) { partialResult, definitions in
            var dic = partialResult
            dic[definitions.0] = definitions.1
            return dic
        }
    }
}

private struct AnonPresentation: Codable {
    struct Identifiers: Codable {
        let schemaId: String
        let credDefId: String
    }

    let identifiers: [Identifiers]
}

private struct ValidateJsonSchemaContainer: Codable {
    let value: AnyCodable
}
