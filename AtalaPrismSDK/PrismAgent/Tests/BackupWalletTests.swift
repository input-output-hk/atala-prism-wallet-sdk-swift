import Apollo
import Castor
import Domain
import Pluto
import Pollux
@testable import PrismAgent
import XCTest

final class BackupWalletTests: XCTestCase {
    let seed = {
        let apollo = ApolloImpl()
        return try! apollo.createSeed(mnemonics: ["pig", "fork", "educate", "gun", "entire", "scatter", "satoshi", "laugh", "project", "buffalo", "race", "enroll", "shiver", "theme", "similar", "thought", "prepare", "velvet", "wild", "mention", "jelly", "match", "document", "rapid"], passphrase: "")
    }()

    func createAgent() throws -> (PrismAgent, MockPluto) {
        let apollo = ApolloImpl()
        let castor = CastorImpl(apollo: apollo)
        let pluto = MockPluto()
        let pollux = MockPollux()
        let agent = PrismAgent(
            apollo: apollo,
            castor: castor,
            pluto: pluto,
            pollux: pollux,
            mercury: MercuryStub(),
            seed: seed
        )
        return (agent, pluto)
    }

    func testBackup() async throws {
        let (backupAgent, backupPluto) = try createAgent()
        _ = try await backupAgent.createNewPeerDID(updateMediator: false)
        _ = try await backupAgent.createNewPrismDID()

        backupPluto.didPairs = [
            .init(
                holder: .init(method: "peer", methodId: "alice"),
                other: .init(method: "peer", methodId: "bob"),
                name: "test"
            )
        ]

        let mockedCredential = MockCredential(exporting: Data(count: 10), restorationType: "mock")
        backupPluto.credentials = [mockedCredential]

        backupPluto.messages = [Message(piuri: "mock", body: Data(count: 20))]
        backupPluto.mediators = [(.init(method: "peer", methodId: "holder"), .init(method: "peer", methodId: "mediator"),.init(method: "peer", methodId: "routing"))]

        // Ask for backup
        let str = try await backupAgent.backupWallet()
        let (receivingAgent, receivingPluto) = try createAgent()
        try await receivingAgent.recoverWallet(encrypted: str)

        XCTAssertEqual(backupPluto.dids.count, receivingPluto.dids.count)
        XCTAssertEqual(backupPluto.credentials.count, receivingPluto.credentials.count)
        XCTAssertEqual(backupPluto.didPairs.count, receivingPluto.didPairs.count)
        XCTAssertEqual(backupPluto.messages.count, receivingPluto.messages.count)
        XCTAssertEqual(backupPluto.mediators.count, receivingPluto.mediators.count)
    }
}
