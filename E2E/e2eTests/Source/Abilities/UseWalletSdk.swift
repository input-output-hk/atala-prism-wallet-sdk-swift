import Foundation
import EdgeAgent
import Builders
import Combine
import Domain
import Pluto
import Core

class UseWalletSdk: Ability {
    static let defaultSeed: Seed = {
        let byteArray: [UInt8] = [69, 191, 35, 232, 213, 102, 3, 93, 180, 106, 224, 144, 79, 171, 79, 223, 154, 217, 235, 232, 96, 30, 248, 92, 100, 38, 38, 42, 101, 53, 2, 247, 56, 111, 148, 220, 237, 122, 15, 120, 55, 82, 89, 150, 35, 45, 123, 135, 159, 140, 52, 127, 239, 148, 150, 109, 86, 145, 77, 109, 47, 60, 20, 16]
        return Seed(value: Data(byteArray))
    }()
    
    static let wrongSeed: Seed = {
        let byteArray: [UInt8] = [69, 191, 35, 232, 213, 102, 3, 93, 180, 106, 224, 144, 79, 171, 79, 223, 154, 217, 235, 232, 96, 30, 248, 92, 100, 38, 38, 42, 101, 53, 2, 247, 57, 111, 148, 220, 237, 122, 15, 120, 55, 82, 89, 150, 35, 45, 123, 135, 159, 140, 52, 127, 239, 148, 150, 109, 86, 145, 77, 109, 47, 60, 20, 16]
        return Seed(value: Data(byteArray))
    }()
    
    lazy var actor: Actor = {
        return actor
    }()
    let abilityName: String = "edge-agent sdk"
    var isInitialized: Bool = false
    
    var credentialOfferStack: [Message] = []
    var issueCredentialStack: [Message] = []
    var proofOfRequestStack: [Message] = []
    var revocationStack: [Message] = []
    var presentationStack: [Message] = []
    
    var receivedMessages: [String] = []
    var cancellables = Set<AnyCancellable>()
    
    lazy var sdk: EdgeAgent = {
        return sdk
    }()

    required init() {}
    
    func initialize() async throws {
        try await createSdk()
        try await startSdk()
        isInitialized = true
    }
    
    func setActor(_ actor: Actor) {
        self.actor = actor
    }
    
    func createSdk(seed: Seed = defaultSeed) async throws {
        let mediatorDID = try await UseWalletSdk.getPrismMediatorDid()
        
        let apollo = ApolloBuilder().build()
        let castor = CastorBuilder(apollo: apollo).build()
        let pluto = PlutoBuilder(setup: .init(
            coreDataSetup: .init(
                modelPath: .storeName("PrismPluto"),
                storeType: .memory
            ),
            keychain: KeychainMock()
        )).build()
        let pollux = PolluxBuilder(pluto: pluto, castor: castor).build()
        let mercury = MercuryBuilder(
            castor: castor,
            secretsStream: UseWalletSdk.createSecretsStream(
                keyRestoration: apollo,
                pluto: pluto,
                castor: castor
            )
        ).build()
        
        EdgeAgent.setupLogging(logLevels: [
            .edgeAgent: .error
        ])
        
        sdk = EdgeAgent(
            apollo: apollo,
            castor: castor,
            pluto: pluto,
            pollux: pollux,
            mercury: mercury,
            mediationHandler: BasicMediatorHandler(
                mediatorDID: mediatorDID,
                mercury: mercury,
                store: BasicMediatorHandler.PlutoMediatorStoreImpl(pluto: pluto)
            ),
            seed: seed
        )
    }
    
    func startSdk() async throws {
        try await sdk.start()
        sdk.handleReceivedMessagesEvents()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Publisher completed successfully.")
                    case .failure(let error):
                        print("Publisher failed with error: \(error)")
                    }
                },
                receiveValue: { message in
                    // FIXME: workaround for receiving multiple messages from the publisher
                    if (self.receivedMessages.contains(message.id)) {
                        return
                    }
                    self.receivedMessages.append(message.id)
                    switch(message.piuri) {
                    case ProtocolTypes.didcommOfferCredential3_0.rawValue:
                        self.credentialOfferStack.append(message)
                    case ProtocolTypes.didcommIssueCredential3_0.rawValue:
                        self.issueCredentialStack.append(message)
                    case ProtocolTypes.didcommRequestPresentation.rawValue:
                        self.proofOfRequestStack.append(message)
                    case ProtocolTypes.didcommRevocationNotification.rawValue:
                        self.revocationStack.append(message)
                    case ProtocolTypes.didcommPresentation.rawValue:
                        self.presentationStack.append(message)
                    default:
                        break
                    }
                }
            )
            .store(in: &cancellables)
        
        sdk.startFetchingMessages()
    }
    
    func tearDown() async throws {
        if (!isInitialized) {
            return
        }
        sdk.stopFetchingMessages()
        try await sdk.stop()
    }
    
    static private func getPrismMediatorDid() async throws -> DID {
        let url = URL(string: Config.mediatorOobUrl)!
        let jsonData: [String: Any] = try await Api.get(from: url)
        let did = (jsonData["from"] as? String)!
        return try DID(string: did)
    }
    
    static private func getRootsMediatorDid() async throws -> DID {
        let url = URL(string: Config.mediatorOobUrl)!
        let invitationUrl: String = try await Api.get(from: url)
        let base64data: String = String(invitationUrl.split(separator: "?_oob=").last!)
        let decodedData = Data(base64Encoded: base64data)!
        let json = try (JSONSerialization.jsonObject(with: decodedData, options: []) as? [String: Any])!
        let from = (json["from"] as? String)!
        return try DID(string: from)
    }
    
    private static func fromBase64(_ encoded: String) -> Data {
        var encoded = encoded;
        let remainder = encoded.count % 4
        if remainder > 0 {
            encoded = encoded.padding(
                toLength: encoded.count + 4 - remainder,
                withPad: "=", startingAt: 0);
        }
        return Data(base64Encoded: encoded)!
    }
    
    static private func createSecretsStream(
        keyRestoration: KeyRestoration,
        pluto: Pluto,
        castor: Castor
    ) -> AnyPublisher<[Secret], Error> {
        pluto.getAllKeys()
            .first()
            .flatMap { keys in
                Future {
                    let privateKeys = await keys.asyncMap {
                        try? await keyRestoration.restorePrivateKey($0)
                    }.compactMap { $0 }
                    return try parsePrivateKeys(
                        privateKeys: privateKeys,
                        castor: castor
                    )
                }
            }
            .eraseToAnyPublisher()
    }
    
    static private func parsePrivateKeys(
        privateKeys: [PrivateKey],
        castor: Castor
    ) throws -> [Domain.Secret] {
        return try privateKeys
            .map { $0 as? (PrivateKey & ExportableKey & StorableKey) }
            .compactMap { $0 }
            .map { privateKey in
                return privateKey
            }
            .map { privateKey in
                try parseToSecret(
                    privateKey: privateKey,
                    identifier: privateKey.identifier
                )
            }
    }
    
    static private func parseToSecret(
        privateKey: PrivateKey & ExportableKey,
        identifier: String
    ) throws -> Domain.Secret {
        let jwk = privateKey.jwk
        guard
            let dataJson = try? JSONEncoder().encode(jwk),
            let stringJson = String(data: dataJson, encoding: .utf8)
        else {
            throw CommonError.invalidCoding(message: "Could not encode privateKey.jwk")
        }
        return .init(
            id: identifier,
            type: .jsonWebKey2020,
            secretMaterial: .jwk(value: stringJson)
        )
    }
}
