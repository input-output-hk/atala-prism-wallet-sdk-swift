import Domain
import Foundation

struct MockPrivateKey: PrivateKey, StorableKey, Equatable {
    let keyType = "testEC"
    let keySpecifications: [String : String]
    let size = 0
    let raw: Data
    var identifier = "TestMockPrivKey"
    var index: Int? = 0
    var queryDerivationPath: String? = nil

    let restorationIdentifier = "MockPrivate"
    var storableData: Data { raw }

    init(str: String = "TestPrivate", curve: KnownKeyCurves = .secp256k1) {
        self.raw = str.data(using: .utf8)!
        self.keySpecifications = [
            KeyProperties.curve.rawValue: curve.rawValue
        ]
    }

    init(raw: Data, curve: KnownKeyCurves = .secp256k1) {
        self.raw = raw
        self.keySpecifications = [
            KeyProperties.curve.rawValue: curve.rawValue
        ]
    }

    func publicKey() -> PublicKey {
        MockPublicKey()
    }

    public static func == (lhs: MockPrivateKey, rhs: MockPrivateKey) -> Bool {
        lhs.raw == rhs.raw
    }
}

struct MockPublicKey: PublicKey, Equatable {
    let keyType = "testEC"
    let keySpecifications = [String : String]()
    let size = 0
    let raw: Data
    var identifier = "TestMockPubKey"

    init(str: String = "TestPublic") {
        self.raw = str.data(using: .utf8)!
    }

    init(raw: Data) {
        self.raw = raw
    }

    func verify(data: Data, signature: Data) throws -> Bool {
        false
    }
}
