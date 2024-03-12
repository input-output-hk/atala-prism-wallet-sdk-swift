import Domain
import Foundation

extension X25519PrivateKey: ExportableKey {
    var pem: String {
        PEMKey(
            keyType: "PRIVATE KEY",
            keyData: raw
        ).pemEncoded()
    }

    var jwk: JWK {
        JWK(
            kty: "OKP",
            kid: identifier,
            d: raw.base64UrlEncodedString(),
            crv: getProperty(.curve)?.capitalized,
            x: publicKey().raw.base64UrlEncodedString()
        )
    }

    func jwkWithKid(kid: String) -> JWK {
        JWK(
            kty: "OKP",
            kid: kid,
            d: raw.base64UrlEncodedString(),
            crv: getProperty(.curve)?.capitalized,
            x: publicKey().raw.base64UrlEncodedString()
        )
    }
}

extension X25519PublicKey: ExportableKey {
    var pem: String {
        PEMKey(
            keyType: "PRIVATE KEY",
            keyData: raw
        ).pemEncoded()
    }

    var jwk: JWK {
        JWK(
            kty: "OKP",
            kid: identifier,
            crv: getProperty(.curve)?.capitalized,
            x: raw.base64UrlEncodedString()
        )
    }

    func jwkWithKid(kid: String) -> JWK {
        JWK(
            kty: "OKP",
            kid: kid,
            crv: getProperty(.curve)?.capitalized,
            x: raw.base64UrlEncodedString()
        )
    }
}
