import ApolloLibrary
import CryptoKit
import Domain
import Foundation

struct Secp256k1PrivateKey: PrivateKey {
    private let internalKey: KMMECSecp256k1PrivateKey
    let keyType: String = "EC"
    let keySpecifications: [String : String]
    let size: Int
    let raw: Data
    let derivationPath: Domain.DerivationPath
    var identifier: String

    init(
        identifier: String = UUID().uuidString,
        internalKey: KMMECSecp256k1PrivateKey,
        derivationPath: Domain.DerivationPath
    ) {
        self.identifier = identifier
        self.internalKey = internalKey
        self.derivationPath = derivationPath
        self.keySpecifications = [
            KeyProperties.curve.rawValue : "secp256k1",
            KeyProperties.derivationPath.rawValue : derivationPath.keyPathString()
        ]

        self.raw = internalKey.raw.toData()
        self.size = internalKey.raw.toData().count
    }

    init(raw: Data, derivationPath: Domain.DerivationPath) {
        self.init(
            internalKey: KMMECSecp256k1PrivateKey(raw: raw.toKotlinByteArray()),
            derivationPath: derivationPath
        )
    }

    func publicKey() -> PublicKey {
        return Secp256k1PublicKey(internalKey: internalKey.getPublicKey())
    }
}

extension Secp256k1PrivateKey: SignableKey {
    var algorithm: String { "ECDSA+SHA256" }

    func sign(data: Data) throws -> Signature {
        Signature(
            algorithm: algorithm,
            signatureSpecifications: ["algorithm" : algorithm],
            raw: internalKey.sign(data: data.toKotlinByteArray()).toData()
        )
    }
}

extension Secp256k1PrivateKey: KeychainStorableKey {
    var restorationIdentifier: String { "secp256k1+priv" }
    var storableData: Data { raw }
    var index: Int? { derivationPath.index }
    var queryDerivationPath: String? { derivationPath.keyPathString() }
    var type: Domain.KeychainStorableKeyProperties.KeyAlgorithm { .rawKey }
    var keyClass: Domain.KeychainStorableKeyProperties.KeyType { .privateKey }
    var accessiblity: Domain.KeychainStorableKeyProperties.Accessability? { .firstUnlock(deviceOnly: true) }
    var synchronizable: Bool { false }
}

struct Secp256k1PublicKey: PublicKey {
    private let internalKey: ApolloLibrary.KMMECSecp256k1PublicKey
    let keyType: String = "EC"
    let keySpecifications: [String : String]
    let size: Int
    let raw: Data
    var identifier = UUID().uuidString

    init(
        identifier: String = UUID().uuidString,
        internalKey: ApolloLibrary.KMMECSecp256k1PublicKey
    ) {
        self.identifier = identifier
        self.internalKey = internalKey
        var specs: [String: String] = [
            KeyProperties.curve.rawValue: "secp256k1",
            KeyProperties.compressedRaw.rawValue: internalKey.getCompressed().toData().base64EncodedString()
        ]
        let points = internalKey.getCurvePoint()
        specs[KeyProperties.curvePointX.rawValue] = points.x.toData().base64EncodedString()
        specs[KeyProperties.curvePointY.rawValue] = points.y.toData().base64EncodedString()

        self.keySpecifications = specs
        self.size = internalKey.raw.toData().count
        self.raw = internalKey.raw.toData()
    }

    init(x: Data, y: Data) {
        self.init(
            internalKey: .Companion().secp256k1FromByteCoordinates(
                x: x.toKotlinByteArray(),
                y: y.toKotlinByteArray()
            )
        )
    }

    init(raw: Data) {
        self.init(internalKey: .Companion().secp256k1FromBytes(encoded: raw.toKotlinByteArray()))
    }

    func verify(data: Data, signature: Data) throws -> Bool {
        internalKey.verify(signature: signature.toKotlinByteArray(), data: data.toKotlinByteArray())
    }
}

extension Secp256k1PublicKey: KeychainStorableKey {
    var restorationIdentifier: String { "secp256k1+pub" }
    var storableData: Data { raw }
    var index: Int? { nil }
    var queryDerivationPath: String? { nil }
    var type: Domain.KeychainStorableKeyProperties.KeyAlgorithm { .rawKey }
    var keyClass: Domain.KeychainStorableKeyProperties.KeyType { .publicKey }
    var accessiblity: Domain.KeychainStorableKeyProperties.Accessability? { .firstUnlock(deviceOnly: true) }
    var synchronizable: Bool { false }
}
