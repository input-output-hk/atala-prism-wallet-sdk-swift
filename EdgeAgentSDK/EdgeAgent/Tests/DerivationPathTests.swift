import Domain
@testable import EdgeAgent
import XCTest

final class DerivationPathTests: XCTestCase {
    func testDerivationPathInitString() throws {
        let derivationStr = "m/29'/29'/0'/1'/2'"
        let derivationPath = try DerivationPath(string: derivationStr)

        XCTAssertEqual(derivationPath.axis.count, 5)
        XCTAssertEqual(derivationPath.axis.map(\.rawValue), [29, 29, 0, 1, 2])
        XCTAssertEqual(derivationPath.index, 29)
    }

    func testDerivationPathInitAxis() throws {
        let derivationAxis: [DerivationPath.Axis] = [
            .hardened(0x1D),
            .hardened(0x1d),
            .hardened(0),
            .hardened(1),
            .hardened(2)
        ]
        let derivationPath = DerivationPath(axis: derivationAxis)

        XCTAssertEqual(derivationPath.axis.count, 5)
        XCTAssertEqual(derivationPath.axis.map(\.rawValue), [29, 29, 0, 1, 2])
        XCTAssertEqual(derivationPath.keyPathString(), "m/29'/29'/0'/1'/2'")
        XCTAssertEqual(derivationPath.index, 29)
    }

    func testDerivationPathSmaller() throws {
        let derivationStr = "m/1'/0'/0'"
        let derivationPath = try DerivationPath(string: derivationStr)

        XCTAssertEqual(derivationPath.axis.count, 3)
        XCTAssertEqual(derivationPath.axis.map(\.rawValue), [1, 0, 0])
        XCTAssertEqual(derivationPath.index, 1)
    }

    func testEdgeAgentDerivationPathMasterKey() throws {
        let edgePath = EdgeAgentDerivationPath(keyPurpose: .master, keyIndex: 1)

        XCTAssertEqual(edgePath.derivationPath.axis.map(\.rawValue), [29, 29, 0, 1, 1])
        XCTAssertEqual(edgePath.derivationPath.keyPathString(), "m/29'/29'/0'/1'/1'")
    }
}
