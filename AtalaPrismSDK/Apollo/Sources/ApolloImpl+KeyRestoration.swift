import Domain
import Foundation

extension ApolloImpl: KeyRestoration {
    public func isPrivateKeyData(identifier: String, data: Data) throws -> Bool {
        identifier.hasSuffix("priv")
    }

    public func isPublicKeyData(identifier: String, data: Data) throws -> Bool {
        identifier.hasSuffix("pub")
    }

    public func isKeyData(identifier: String, data: Data) throws -> Bool {
        identifier.hasSuffix("key")
    }

    public func restorePrivateKey(_ key: StorableKey) throws -> PrivateKey {
        switch  key.restorationIdentifier {
        case "secp256k1+priv":
            guard let index = key.index else {
                throw ApolloError.restoratonFailedNoIdentifierOrInvalid
            }
            return Secp256k1PrivateKey(
                identifier: key.identifier,
                internalKey: .init(raw: key.storableData.toKotlinByteArray()), derivationPath: DerivationPath(index: index)
            )
        case "x25519+priv":
            return try CreateX25519KeyPairOperation(logger: Self.logger)
                .compute(
                    identifier: key.identifier,
                    fromPrivateKey: key.storableData
                )
        case "ed25519+priv":
            return try CreateEd25519KeyPairOperation(logger: Self.logger)
                .compute(
                    identifier: key.identifier,
                    fromPrivateKey: key.storableData
                )
        default:
            throw ApolloError.restoratonFailedNoIdentifierOrInvalid
        }

    }

    public func restorePublicKey(_ key: StorableKey) throws -> PublicKey {
        switch key.restorationIdentifier {
        case "secp256k1+pub":
            return Secp256k1PublicKey(
                identifier: key.identifier,
                internalKey: .init(raw: key.storableData.toKotlinByteArray())
            )
        case "x25519+pub":
            return X25519PublicKey(
                identifier: key.identifier,
                internalKey: .init(raw: key.storableData.toKotlinByteArray())
            )
        case "ed25519+pub":
            return Ed25519PublicKey(
                identifier: key.identifier,
                internalKey: .init(raw: key.storableData.toKotlinByteArray())
            )
        default:
            throw ApolloError.restoratonFailedNoIdentifierOrInvalid
        }
    }

    public func restoreKey(_ key: StorableKey) async throws -> Key {
        switch key.restorationIdentifier {
        case "secp256k1+priv":
            guard let index = key.index else {
                throw ApolloError.restoratonFailedNoIdentifierOrInvalid
            }
            return Secp256k1PrivateKey(
                identifier: key.identifier,
                internalKey: .init(raw: key.storableData.toKotlinByteArray()), derivationPath: DerivationPath(index: index)
            )
        case "x25519+priv":
            return try CreateX25519KeyPairOperation(logger: Self.logger)
                .compute(
                    identifier: key.identifier,
                    fromPrivateKey: key.storableData
                )
        case "ed25519+priv":
            return try CreateEd25519KeyPairOperation(logger: Self.logger)
                .compute(
                    identifier: key.identifier,
                    fromPrivateKey: key.storableData
                )
        case "secp256k1+pub":
            return Secp256k1PublicKey(
                identifier: key.identifier,
                internalKey: .init(raw: key.storableData.toKotlinByteArray())
            )
        case "x25519+pub":
            return X25519PublicKey(
                identifier: key.identifier,
                internalKey: .init(raw: key.storableData.toKotlinByteArray())
            )
        case "ed25519+pub":
            return Ed25519PublicKey(
                identifier: key.identifier,
                internalKey: .init(raw: key.storableData.toKotlinByteArray())
            )
        case "linkSecret+key":
            return try LinkSecret(data: key.storableData)
        default:
            throw ApolloError.restoratonFailedNoIdentifierOrInvalid
        }
    }

    public func restoreKey(_ key: JWK, index: Int?) async throws -> Key {
        switch key.kty {
        case "EC":
            switch key.crv?.lowercased() {
            case "secp256k1":
                guard
                    let d = key.d,
                    let dData = Data(fromBase64URL: d)
                else {
                    guard
                        let x = key.x,
                        let y = key.y,
                        let xData = Data(fromBase64URL: x),
                        let yData = Data(fromBase64URL: y)
                    else {
                        throw ApolloError.invalidJWKError
                    }
                    return Secp256k1PublicKey(
                        identifier: key.kid ?? UUID().uuidString,
                        internalKey: .init(raw: (xData + yData).toKotlinByteArray())
                    )
                }
                return Secp256k1PrivateKey(
                    identifier: key.kid ?? UUID().uuidString,
                    internalKey: .init(raw: dData.toKotlinByteArray()), derivationPath: DerivationPath(index: index ?? 0)
                )
            default:
                throw ApolloError.invalidKeyCurve(invalid: key.crv ?? "", valid: ["secp256k1"])
            }
        case "OKP":
            switch key.crv?.lowercased() {
            case "ed25519":
                guard
                    let d = key.d,
                    let dData = Data(fromBase64URL: d)
                else {
                    guard
                        let x = key.x,
                        let xData = Data(fromBase64URL: x)
                    else {
                        throw ApolloError.invalidJWKError
                    }
                    return Ed25519PublicKey(
                        identifier: key.kid ?? UUID().uuidString,
                        internalKey: .init(raw: xData.toKotlinByteArray())
                    )
                }
                return Ed25519PrivateKey(
                    identifier: key.kid ?? UUID().uuidString,
                    internalKey: .init(raw: dData.toKotlinByteArray())
                )
            case "x25519":
                guard
                    let d = key.d,
                    let dData = Data(fromBase64URL: d)
                else {
                    guard
                        let x = key.x,
                        let xData = Data(fromBase64URL: x)
                    else {
                        throw ApolloError.invalidJWKError
                    }
                    return X25519PublicKey(
                        identifier: key.kid ?? UUID().uuidString,
                        internalKey: .init(raw: xData.toKotlinByteArray())
                    )
                }
                return X25519PrivateKey(
                    identifier: key.kid ?? UUID().uuidString,
                    internalKey: .init(raw: dData.toKotlinByteArray())
                )
            default:
                throw ApolloError.invalidKeyCurve(invalid: key.crv ?? "", valid: ["ed25519", "x25519"])
            }
        default:
            throw ApolloError.invalidKeyType(invalid: key.kty, valid: ["EC", "OKP"])
        }
    }
}
