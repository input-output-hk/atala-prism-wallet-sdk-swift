import ApolloLibrary
import CryptoKit
import Core
import Domain
import Foundation

struct CreateX25519KeyPairOperation {
    let logger: SDKLogger

    func compute() -> PrivateKey {
        let privateKey = KMMX25519KeyPair.Companion().generateKeyPair().privateKey
        return X25519PrivateKey(internalKey: privateKey)

    }

    func compute(
        identifier: String = UUID().uuidString,
        fromPrivateKey: Data,
        derivationPath: Domain.DerivationPath? = nil
    ) throws -> PrivateKey {
        let privateKey = KMMX25519PrivateKey(raw: fromPrivateKey.toKotlinByteArray())
        return X25519PrivateKey(
            identifier: identifier,
            internalKey: privateKey,
            derivationPath: derivationPath
        )
    }

    func compute(seed: Seed, keyPath: Domain.DerivationPath) throws -> PrivateKey {
        let derivedHdKey = ApolloLibrary
            .EdHDKey
            .companion
            .doInitFromSeed(seed: seed.value.toKotlinByteArray())
            .derive(path: keyPath.keyPathString()
        )

        return X25519PrivateKey(
            internalKey: KMMEdPrivateKey(raw: derivedHdKey.privateKey).x25519PrivateKey(),
            derivationPath: keyPath
        )
    }
}
