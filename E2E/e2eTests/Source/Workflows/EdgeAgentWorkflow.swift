import Foundation
import Domain
import PrismAgent

class EdgeAgentWorkflow {
    static func connectsThroughTheInvite(edgeAgent: Actor) async throws {
        let invitation: String = try edgeAgent.recall(key: "invitation")
        let url = URL(string: invitation)!
        
        let oob = try edgeAgent.using(
            ability: Sdk.self,
            action: "parses an OOB invitation"
        ).prismAgent.parseOOBInvitation(url: url)
        
        try await edgeAgent.using(
            ability: Sdk.self,
            action: "accepts an invitation"
        ).prismAgent.acceptDIDCommInvitation(invitation: oob)
    }
    
    static func waitToReceiveCredentialsOffer(edgeAgent: Actor, numberOfCredentials: Int) async throws {
        try await edgeAgent.waitUsingAbility(
            ability: Sdk.self,
            action: "credential offer count to be \(numberOfCredentials)"
        ) { ability in
            return ability.credentialOfferStack.count == numberOfCredentials
        }
    }
    
    static func hasIssuedCredentials(edgeAgent: Actor, numberOfCredentialsIssued: Int, cloudAgent: Actor) async throws {
        for _ in 0..<numberOfCredentialsIssued {
            try await CloudAgentWorkflow.offersACredential(cloudAgent: cloudAgent)
            try await EdgeAgentWorkflow.waitToReceiveCredentialsOffer(edgeAgent: edgeAgent, numberOfCredentials: 1)
            try await EdgeAgentWorkflow.acceptsTheCredentialOffer(edgeAgent: edgeAgent)
            let recordId: String = try cloudAgent.recall(key: "recordId")
            try await CloudAgentWorkflow.verifyCredentialState(cloudAgent: cloudAgent, recordId: recordId, expectedState: .CredentialSent)
            try await EdgeAgentWorkflow.waitToReceiveIssuedCredentials(edgeAgent: edgeAgent, numberOfCredentials: 1)
            try await EdgeAgentWorkflow.processIssuedCredentials(edgeAgent: edgeAgent, numberOfCredentials: 1)
        }
    }
    
    static func hasIssuedAnonymousCredentials(edgeAgent: Actor, numberOfCredentialsIssued: Int, cloudAgent: Actor) async throws {
        for _ in 0..<numberOfCredentialsIssued {
            try await CloudAgentWorkflow.offersAnonymousCredential(cloudAgent: cloudAgent)
            try await EdgeAgentWorkflow.waitToReceiveCredentialsOffer(edgeAgent: edgeAgent, numberOfCredentials: 1)
            try await EdgeAgentWorkflow.acceptsTheCredentialOffer(edgeAgent: edgeAgent)
            let recordId: String = try cloudAgent.recall(key: "recordId")
            try await CloudAgentWorkflow.verifyCredentialState(cloudAgent: cloudAgent, recordId: recordId, expectedState: .CredentialSent)
            try await EdgeAgentWorkflow.waitToReceiveIssuedCredentials(edgeAgent: edgeAgent, numberOfCredentials: 1)
            try await EdgeAgentWorkflow.processIssuedCredentials(edgeAgent: edgeAgent, numberOfCredentials: 1)
        }
    }
    
    static func acceptsTheCredentialOffer(edgeAgent: Actor) async throws {
        let message: Message = try edgeAgent.using(
            ability: Sdk.self,
            action: "gets the first credential offer"
        ).credentialOfferStack.first!
        
        try edgeAgent.using(
            ability: Sdk.self,
            action: "removes it from list"
        ).credentialOfferStack.removeFirst()
        
        let acceptOfferMessage = try OfferCredential3_0.init(fromMessage: message)
        let did = try await edgeAgent.using(
            ability: Sdk.self,
            action: "create a new prism DID"
        ).prismAgent.createNewPrismDID()
        
        let requestCredential = try await edgeAgent
            .using(
                ability: Sdk.self,
                action: "request a credential"
            )
            .prismAgent
            .prepareRequestCredentialWithIssuer(
                did: did,
                offer: acceptOfferMessage
            )!.makeMessage()
        
        _ = try await edgeAgent.using(
            ability: Sdk.self,
            action: "send a message"
        ).prismAgent.sendMessage(message: requestCredential)
    }
    
    static func waitToReceiveIssuedCredentials(edgeAgent: Actor, numberOfCredentials: Int) async throws {
        try await edgeAgent.waitUsingAbility(
            ability: Sdk.self,
            action: "wait for issued credentials to be \(numberOfCredentials)"
        ) { ability in
            return ability.issueCredentialStack.count == numberOfCredentials
        }
    }
    
    static func processIssuedCredentials(edgeAgent: Actor, numberOfCredentials: Int) async throws {
        for _ in 0..<numberOfCredentials {
            let message = try edgeAgent.using(
                ability: Sdk.self,
                action: "get an issued credential"
            ).issueCredentialStack.first!
            try edgeAgent.using(
                ability: Sdk.self,
                action: "remove it from list"
            ).issueCredentialStack.removeFirst()
            let issuedCredential = try IssueCredential3_0(fromMessage: message)
            _ = try await edgeAgent.using(
                ability: Sdk.self,
                action: "process the credential"
            ).prismAgent.processIssuedCredentialMessage(message: issuedCredential)
        }
    }
    
    static func waitForProofRequest(edgeAgent: Actor) async throws {
        try await edgeAgent.waitUsingAbility(
            ability: Sdk.self,
            action: "wait for present proof request"
        ) { ability in
            return ability.proofOfRequestStack.count == 1
        }
    }
    
    static func presentProof(edgeAgent: Actor) async throws {
        let credential = try await edgeAgent.using(
            ability: Sdk.self,
            action: "get a verifiable credential"
        ).prismAgent.verifiableCredentials().map { $0.first }.first().await()
        
        let message = try edgeAgent.using(
            ability: Sdk.self,
            action: "get proof request"
        ).proofOfRequestStack.first!
        try edgeAgent.using(
            ability: Sdk.self,
            action: "remove it from list"
        ).proofOfRequestStack.removeFirst()
        let requestPresentationMessage = try RequestPresentation(fromMessage: message)
        let sendProofMessage = try await edgeAgent.using(
            ability: Sdk.self,
            action: "make message"
        ).prismAgent.createPresentationForRequestProof(request: requestPresentationMessage, credential: credential!).makeMessage()
        do {
            _ = try await edgeAgent.using(
                ability: Sdk.self,
                action: "send message"
            ).prismAgent.sendMessage(message: sendProofMessage)
        } catch {
            print("error", error)
        }
    }
}
