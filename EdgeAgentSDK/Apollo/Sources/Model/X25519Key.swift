import ApolloLibrary
import Domain
import Foundation

struct X25519PrivateKey: PrivateKey {
    private let internalKey: ApolloLibrary.KMMX25519PrivateKey
    let keyType: String = "EC"
    let keySpecifications: [String : String]
    let derivationPath: Domain.DerivationPath?
    var identifier:String
    var size: Int { raw.count }
    var raw: Data { internalKey.raw.toData() }

    init(
        identifier: String = UUID().uuidString,
        internalKey: ApolloLibrary.KMMX25519PrivateKey,
        derivationPath: Domain.DerivationPath? = nil
    ) {
        self.identifier = identifier
        self.internalKey = internalKey
        var keySpecifications = ["curve" : "x25519"]
        derivationPath.map { keySpecifications[KeyProperties.derivationPath.rawValue] = $0.keyPathString() }
        self.keySpecifications = keySpecifications
        self.derivationPath = derivationPath
    }

    func publicKey() -> PublicKey {
        guard let publicKey = try? internalKey.publicKey() else {
            // TODO: This should never happen, but now we need to confirm if the Apollo domain needs to handle throwing or the library needs to remove it
            fatalError("This should never happen. PrivateKeys should always build a public")
        }
        return X25519PublicKey(internalKey: publicKey)
        
    }
}

extension X25519PrivateKey: KeychainStorableKey {
    var restorationIdentifier: String { "x25519+priv" }
    var storableData: Data { raw }
    var index: Int? { nil }
    var queryDerivationPath: String? { derivationPath?.keyPathString() }
    var type: Domain.KeychainStorableKeyProperties.KeyAlgorithm { .rawKey }
    var keyClass: Domain.KeychainStorableKeyProperties.KeyType { .privateKey }
    var accessiblity: Domain.KeychainStorableKeyProperties.Accessability? { .firstUnlock(deviceOnly: true) }
    var synchronizable: Bool { false }
}

struct X25519PublicKey: PublicKey {
    private let internalKey: ApolloLibrary.KMMX25519PublicKey
    let keyType: String = "EC"
    let keySpecifications: [String : String] = [
        "curve" : "x25519"
    ]
    var identifier: String
    var size: Int { raw.count }
    var raw: Data { internalKey.raw.toData() }

    init(
        identifier: String = UUID().uuidString,
        internalKey: ApolloLibrary.KMMX25519PublicKey
    ) {
        self.identifier = identifier
        self.internalKey = internalKey
    }

    init(raw: Data) {
        self.init(internalKey: .init(raw: raw.toKotlinByteArray()))
    }

    func verify(data: Data, signature: Data) throws -> Bool {
        throw ApolloError.keyAgreementDoesNotSupportVerification
    }
}

extension X25519PublicKey: KeychainStorableKey {
    var restorationIdentifier: String { "x25519+pub" }
    var storableData: Data { raw }
    var index: Int? { nil }
    var queryDerivationPath: String? { nil }
    var type: Domain.KeychainStorableKeyProperties.KeyAlgorithm { .rawKey }
    var keyClass: Domain.KeychainStorableKeyProperties.KeyType { .publicKey }
    var accessiblity: Domain.KeychainStorableKeyProperties.Accessability? { .firstUnlock(deviceOnly: true) }
    var synchronizable: Bool { false }
}
