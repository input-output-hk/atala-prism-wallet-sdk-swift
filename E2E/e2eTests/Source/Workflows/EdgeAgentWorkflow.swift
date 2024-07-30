import Foundation
import Domain
import EdgeAgent
import XCTest
import PeerDID
import Combine
import SwiftHamcrest

class EdgeAgentWorkflow {
    static func connectsThroughTheInvite(edgeAgent: Actor) async throws {
        let invitation: String = try await edgeAgent.recall(key: "invitation")
        let url = URL(string: invitation)!
        
        let oob = try await edgeAgent.using(
            ability: UseWalletSdk.self,
            action: "parses an OOB invitation"
        ).sdk.parseOOBInvitation(url: url)
        
        try await edgeAgent.using(
            ability: UseWalletSdk.self,
            action: "accepts an invitation"
        ).sdk.acceptDIDCommInvitation(invitation: oob)
    }
    
    static func waitToReceiveCredentialsOffer(edgeAgent: Actor, numberOfCredentials: Int) async throws {
        try await edgeAgent.waitUsingAbility(
            ability: UseWalletSdk.self,
            action: "credential offer count to be \(numberOfCredentials)"
        ) { ability in
            return ability.credentialOfferStack.count == numberOfCredentials
        }
    }
    
    static func hasIssuedCredentials(edgeAgent: Actor, numberOfCredentialsIssued: Int, cloudAgent: Actor) async throws {
        var recordIdList: [String] = []
        for _ in 0..<numberOfCredentialsIssued {
            try await CloudAgentWorkflow.offersACredential(cloudAgent: cloudAgent)
            try await EdgeAgentWorkflow.waitToReceiveCredentialsOffer(edgeAgent: edgeAgent, numberOfCredentials: 1)
            try await EdgeAgentWorkflow.acceptsTheCredentialOffer(edgeAgent: edgeAgent)
            let recordId: String = try await cloudAgent.recall(key: "recordId")
            recordIdList.append(recordId)
            try await CloudAgentWorkflow.verifyCredentialState(cloudAgent: cloudAgent, recordId: recordId, expectedState: .CredentialSent)
            try await EdgeAgentWorkflow.waitToReceiveIssuedCredentials(edgeAgent: edgeAgent, numberOfCredentials: 1)
            try await EdgeAgentWorkflow.processIssuedCredential(edgeAgent: edgeAgent, recordId: recordId)
        }
        try await cloudAgent.remember(key: "recordIdList", value: recordIdList)
    }
    
    static func hasIssuedAnonymousCredentials(edgeAgent: Actor, numberOfCredentialsIssued: Int, cloudAgent: Actor) async throws {
        var recordIdList: [String] = []
        for _ in 0..<numberOfCredentialsIssued {
            try await CloudAgentWorkflow.offersAnonymousCredential(cloudAgent: cloudAgent)
            try await EdgeAgentWorkflow.waitToReceiveCredentialsOffer(edgeAgent: edgeAgent, numberOfCredentials: 1)
            try await EdgeAgentWorkflow.acceptsTheCredentialOffer(edgeAgent: edgeAgent)
            let recordId: String = try await cloudAgent.recall(key: "recordId")
            recordIdList.append(recordId)
            try await CloudAgentWorkflow.verifyCredentialState(cloudAgent: cloudAgent, recordId: recordId, expectedState: .CredentialSent)
            try await EdgeAgentWorkflow.waitToReceiveIssuedCredentials(edgeAgent: edgeAgent, numberOfCredentials: 1)
            try await EdgeAgentWorkflow.processIssuedCredential(edgeAgent: edgeAgent, recordId: recordId)
        }
        try await cloudAgent.remember(key: "recordIdList", value: recordIdList)
    }
    
    static func acceptsTheCredentialOffer(edgeAgent: Actor) async throws {
        let message: Message = try await edgeAgent.using(
            ability: UseWalletSdk.self,
            action: "gets the first credential offer"
        ).credentialOfferStack.first!
        
        try await edgeAgent.using(
            ability: UseWalletSdk.self,
            action: "removes it from list"
        ).credentialOfferStack.removeFirst()
        
        let acceptOfferMessage = try OfferCredential3_0.init(fromMessage: message)
        let did = try await edgeAgent.using(
            ability: UseWalletSdk.self,
            action: "create a new prism DID"
        ).sdk.createNewPrismDID()
        
        let requestCredential = try await edgeAgent
            .using(
                ability: UseWalletSdk.self,
                action: "request a credential"
            )
            .sdk
            .prepareRequestCredentialWithIssuer(
                did: did,
                offer: acceptOfferMessage
            )!.makeMessage()
        
        _ = try await edgeAgent.using(
            ability: UseWalletSdk.self,
            action: "send a message"
        ).sdk.sendMessage(message: requestCredential)
    }
    
    static func waitToReceiveIssuedCredentials(edgeAgent: Actor, numberOfCredentials: Int) async throws {
        try await edgeAgent.waitUsingAbility(
            ability: UseWalletSdk.self,
            action: "wait for issued credentials to be \(numberOfCredentials)"
        ) { ability in
            return ability.issueCredentialStack.count == numberOfCredentials
        }
    }
    
    static func processIssuedCredential(edgeAgent: Actor, recordId: String) async throws {
        let message = try await edgeAgent
            .using(ability: UseWalletSdk.self, action: "get the issued credential message")
            .issueCredentialStack.removeFirst()
        let issuedCredential = try IssueCredential3_0(fromMessage: message)
        _ = try await edgeAgent
            .using(ability: UseWalletSdk.self, action: "process the credential")
            .sdk.processIssuedCredentialMessage(message: issuedCredential)
        try await edgeAgent.remember(key: recordId, value: message.id)
    }
    
    static func waitForProofRequest(edgeAgent: Actor) async throws {
        try await edgeAgent.waitUsingAbility(
            ability: UseWalletSdk.self,
            action: "wait for present proof request"
        ) { ability in
            return ability.proofOfRequestStack.count == 1
        }
    }
    
    static func presentProof(edgeAgent: Actor) async throws {
        let credential = try await edgeAgent.using(
            ability: UseWalletSdk.self,
            action: "get a verifiable credential"
        ).sdk.verifiableCredentials().map { $0.first }.first().await()
        
        let message = try await edgeAgent.using(
            ability: UseWalletSdk.self,
            action: "get proof request"
        ).proofOfRequestStack.first!
        try await edgeAgent.using(
            ability: UseWalletSdk.self,
            action: "remove it from list"
        ).proofOfRequestStack.removeFirst()
        let requestPresentationMessage = try RequestPresentation(fromMessage: message)
        let sendProofMessage = try await edgeAgent.using(
            ability: UseWalletSdk.self,
            action: "make message"
        ).sdk.createPresentationForRequestProof(request: requestPresentationMessage, credential: credential!).makeMessage()
        _ = try await edgeAgent.using(
            ability: UseWalletSdk.self,
            action: "send message"
        ).sdk.sendMessage(message: sendProofMessage)
    }
    
    static func shouldNotBeAbleToCreatePresentProof(edgeAgent: Actor) async throws {
        await assertThrows(try await presentProof(edgeAgent: edgeAgent))
    }
    
    static func createBackup(edgeAgent: Actor) async throws {
        let backup = try await edgeAgent.using(ability: UseWalletSdk.self, action: "creates a backup").sdk.backupWallet()
        let seed = try await edgeAgent.using(ability: UseWalletSdk.self, action: "gets seed phrase").sdk.seed
        try await edgeAgent.remember(key: "backup", value: backup)
        try await edgeAgent.remember(key: "seed", value: seed)
    }
    
    static func createNewWalletFromBackup(edgeAgent: Actor) async throws {
        let backup: String = try await edgeAgent.recall(key: "backup")
        let seed: Seed = try await edgeAgent.recall(key: "seed")
        let walletSdk = UseWalletSdk()
        try await walletSdk.createSdk(seed: seed)
        try await walletSdk.sdk.recoverWallet(encrypted: backup)
        try await walletSdk.sdk.start()
        try await walletSdk.sdk.stop()
    }
    
    static func createNewWalletFromBackupWithWrongSeed(edgeAgent: Actor) async throws {
        let backup: String = try await edgeAgent.recall(key: "backup")
        let seed = UseWalletSdk.wrongSeed
        
        do {
            let walletSdk = UseWalletSdk()
            try await walletSdk.createSdk(seed: seed)
            try await walletSdk.sdk.recoverWallet(encrypted: backup)
            XCTFail("SDK should not be able to restore with wrong seed phrase.")
        } catch {
        }
    }
    
    static func createPeerDids(edgeAgent: Actor, numberOfDids: Int) async throws {
        for _ in 0..<numberOfDids {
            let did: DID = try await edgeAgent.using(ability: UseWalletSdk.self, action: "creates peer did")
                .sdk.createNewPeerDID(updateMediator: true)
            try await edgeAgent.remember(key: "lastPeerDid", value: did)
        }
        
    }
    
    static func createPrismDids(edgeAgent: Actor, numberOfDids: Int) async throws {
        for _ in 0..<numberOfDids {
            _ = try await edgeAgent.using(ability: UseWalletSdk.self, action: "creates peer did").sdk.createNewPrismDID()
        }
    }
    
    static func backupAndRestoreToNewAgent(newAgent: Actor, oldAgent: Actor) async throws {
        let backup: String = try await oldAgent.recall(key: "backup")
        let seed: Seed = try await oldAgent.recall(key: "seed")
        let walletSdk = UseWalletSdk()
        try await walletSdk.createSdk(seed: seed)
        try await walletSdk.sdk.recoverWallet(encrypted: backup)
        try await walletSdk.startSdk()
        walletSdk.isInitialized = true
        _ = newAgent.whoCanUse(walletSdk)
    }
    
    static func newAgentShouldMatchOldAgent(newAgent: Actor, oldAgent: Actor) async throws {
        let expectedCredentials: [Credential] = try await oldAgent.using(
            ability: UseWalletSdk.self,
            action: "gets credentials"
        ).sdk.verifiableCredentials().first().await()
        let expectedPeerDids: [PeerDID] = try await oldAgent.using(
            ability: UseWalletSdk.self,
            action: "gets peer dids"
        ).sdk.pluto.getAllPeerDIDs().first().await().map { try PeerDID(didString: $0.did.string) }
        let expectedPrismDids: [DID] = try await oldAgent.using(
            ability: UseWalletSdk.self,
            action: "gets prism dids"
        ).sdk.pluto.getAllPrismDIDs().first().await().map { try DID(string: $0.did.string) }
        let expectedDidPairs: [DIDPair] = try await oldAgent.using(
            ability: UseWalletSdk.self,
            action: "gets did pairs"
        ).sdk.pluto.getAllDidPairs().first().await()
        
        let actualCredentials: [Credential] = try await newAgent.using(
            ability: UseWalletSdk.self,
            action: "gets credentials"
        ).sdk.verifiableCredentials().first().await()
        let actualPeerDids: [PeerDID] = try await newAgent.using(
            ability: UseWalletSdk.self,
            action: "gets peer dids"
        ).sdk.pluto.getAllPeerDIDs().first().await().map { try PeerDID(didString: $0.did.string) }
        let actualPrismDids: [DID] = try await newAgent.using(
            ability: UseWalletSdk.self,
            action: "gets prism dids"
        ).sdk.pluto.getAllPrismDIDs().first().await().map { try DID(string: $0.did.string) }
        let actualDidPairs: [DIDPair] = try await newAgent.using(
            ability: UseWalletSdk.self,
            action: "gets did pairs"
        ).sdk.pluto.getAllDidPairs().first().await()
        
        assertThat(expectedCredentials.count == actualCredentials.count)
        assertThat(expectedPeerDids.count == actualPeerDids.count)
        assertThat(expectedPrismDids.count == actualPrismDids.count)
        assertThat(expectedDidPairs.count == actualDidPairs.count)
        
        expectedCredentials.forEach { expectedCredential in
            assertThat(actualCredentials.contains(where: { $0.id == expectedCredential.id }), equalTo(true))
        }
        expectedPeerDids.forEach { expectedPeerDid in
            assertThat(actualPeerDids.contains(where: { $0.string == expectedPeerDid.string }), equalTo(true))
        }
        expectedPrismDids.forEach { expectedPrismDid in
            assertThat(actualPrismDids.contains(where: { $0.string == expectedPrismDid.string }), equalTo(true))
        }
        expectedDidPairs.forEach { expectedDidPair in
            assertThat(actualDidPairs.contains(where: { $0.name == expectedDidPair.name }), equalTo(true))
        }
    }
    
    static func waitForCredentialRevocationMessage(edgeAgent: Actor, numberOfRevocation: Int) async throws {
        try await edgeAgent.waitUsingAbility(
            ability: UseWalletSdk.self,
            action: "wait for revocation notification"
        ) { ability in
            return ability.revocationStack.count == numberOfRevocation
        }
    }
    
    static func waitUntilCredentialIsRevoked(edgeAgent: Actor, revokedRecordIdList: [String]) async throws {
        var revokedIdList: [String] = []
        for revokedRecordId in revokedRecordIdList {
            revokedIdList.append(try await edgeAgent.recall(key: revokedRecordId))
        }
        let credentials = try await edgeAgent.using(ability: UseWalletSdk.self, action: "")
            .sdk.verifiableCredentials().first().await()
        
        var revokedCredentials: [Credential] = []
        for credential in credentials {
            if ((try await credential.revocable?.isRevoked) != nil) {
                revokedCredentials.append(credential)
            }
        }
        assertThat(revokedRecordIdList.count, equalTo(revokedCredentials.count))
    }
    
    static func initiatePresentationRequest(
        edgeAgent: Actor,
        credentialType: CredentialType,
        toDid: DID,
        claims: [ClaimFilter]
    ) async throws {
        let hostDid: DID = try await edgeAgent.using(ability: UseWalletSdk.self, action: "creates peer did")
            .sdk.createNewPeerDID(updateMediator: true)
        let request = try await edgeAgent.using(ability: UseWalletSdk.self, action: "creates verification request")
            .sdk.initiatePresentationRequest(
                type: credentialType,
                fromDID: hostDid,
                toDID: toDid,
                claimFilters: claims
            )
        _ = try await edgeAgent.using(ability: UseWalletSdk.self, action: "sends verification request")
            .sdk.sendMessage(message: request.makeMessage())
    }
    
    static func waitForPresentationMessage(edgeAgent: Actor, numberOfPresentations: Int = 1) async throws {
        try await edgeAgent.waitUsingAbility(
            ability: UseWalletSdk.self,
            action: "waits for presentation message"
        ) { ability in
            return ability.presentationStack.count == numberOfPresentations
        }
    }
    
    static func verifyPresentation(edgeAgent: Actor, expected: Bool = true) async throws {
        let presentation = try await edgeAgent.using(ability: UseWalletSdk.self, action: "retrieves presentation message")
            .presentationStack.removeFirst()
        do {
            let result = try await edgeAgent.using(ability: UseWalletSdk.self, action: "")
                .sdk.verifyPresentation(message: presentation)
            assertThat(result, equalTo(expected))
        } catch PolluxError.cannotVerifyPresentationInputs {
            
            print("teste")
            //              if (e.message.includes("credential is revoked")) {
            //                assert.isTrue(expected === false)
            //              } else {
            //                throw e
            //              }
        }
    }
}
