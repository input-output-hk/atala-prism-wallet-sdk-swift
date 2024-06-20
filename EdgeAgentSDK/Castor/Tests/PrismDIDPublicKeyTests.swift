import Apollo
@testable import Castor
import Domain
import SwiftProtobuf
import XCTest

final class PrismDIDPublicKeyTests: XCTestCase {
    var seed: Seed!
    var privateKey: PrivateKey!
    var apollo: Apollo!

    override func setUp() async throws {
        apollo = ApolloImpl()
        seed = apollo.createRandomSeed().seed
        privateKey = try await apollo.createPrivateKey(parameters: [
            KeyProperties.type.rawValue: "EC",
            KeyProperties.curve.rawValue: KnownKeyCurves.secp256k1.rawValue,
            KeyProperties.seed.rawValue: seed.value.base64Encoded(),
            KeyProperties.derivationPath.rawValue: DerivationPath().keyPathString()
        ])
    }

    func testFromProto() throws {
        let publicKey = PrismDIDPublicKey(
            apollo: apollo,
            id: PrismDIDPublicKey.Usage.masterKey.id(index: 0),
            usage: .masterKey,
            keyData: privateKey.publicKey()
        )

        let protoData = try publicKey.toProto().serializedData()
        let proto = try Io_Iohk_Atala_Prism_Protos_PublicKey(serializedData: protoData)
        let parsedPublicKey = try PrismDIDPublicKey(apollo: apollo, proto: proto)
        XCTAssertEqual(parsedPublicKey.id, "master0")
        XCTAssertEqual(parsedPublicKey.keyData.raw, publicKey.keyData.raw)
        XCTAssertEqual(parsedPublicKey.usage, publicKey.usage)
    }
}
