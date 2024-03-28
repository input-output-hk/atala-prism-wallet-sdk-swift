import Foundation

class CloudAgentSteps: Steps {
    @Step("{actor} offers an anonymous credential")
    var cloudAgentOffersAnAnonymousCredential = { (cloudAgent: Actor) in
        try await CloudAgentWorkflow.offersAnonymousCredential(cloudAgent: cloudAgent)
    }
    
    @Step("{actor} asks for present-proof")
    var cloudAgentAsksForPresentProof = { (cloudAgent: Actor) in
        try await CloudAgentWorkflow.asksForPresentProof(cloudAgent: cloudAgent)
    }

    @Step("{actor} asks for anonymous present-proof")
    var cloudAgentAsksForAnonymousPresentProof = { (cloudAgent: Actor) in
        try await CloudAgentWorkflow.asksForAnonymousPresentProof(cloudAgent: cloudAgent)
    }
    
    @Step("{actor} should see the present-proof is verified")
    var cloudAgentShouldSeeThePresentProofIsVerified = { (cloudAgent: Actor) in
        try await CloudAgentWorkflow.verifyPresentProof(cloudAgent: cloudAgent, expectedState: .PresentationVerified)
    }
    
    @Step("{actor} offers a credential")
    var cloudAgentOffersACredential = { (cloudAgent: Actor) in
        try await CloudAgentWorkflow.offersACredential(cloudAgent: cloudAgent)
    }
    
    @Step("{actor} should see the credential was accepted")
    var cloudAgentShouldSeeTheCredentialWasAccepted = { (cloudAgent: Actor) in
        let recordId: String = try cloudAgent.recall(key: "recordId")
        try await CloudAgentWorkflow.verifyCredentialState(cloudAgent: cloudAgent, recordId: recordId, expectedState: .CredentialSent)
    }
    
    @Step("{actor} should see all credentials were accepted")
    var cloudAgentSeeAllCredentialsWereAccepted = { (cloudAgent: Actor) in
        let recordIdList: [String] = try cloudAgent.recall(key: "recordIdList")
        for recordId in recordIdList {
            try await CloudAgentWorkflow.verifyCredentialState(cloudAgent: cloudAgent, recordId: recordId, expectedState: .CredentialSent)
        }
    }
    
    @Step("{actor} is connected to {actor}")
    var cloudAgentIsConnectedToEdgeAgent = { (cloudAgent: Actor, edgeAgent: Actor) in
        try await CloudAgentWorkflow.isConnectedToEdgeAgent(cloudAgent: cloudAgent, edgeAgent: edgeAgent)
    }
    
    @Step("{actor} has a connection invitation")
    var cloudAgentHasAConnectionInvitation = { (cloudAgent: Actor) in
        try await CloudAgentWorkflow.hasAConnectionInvitation(cloudAgent: cloudAgent)
    }
    
    @Step("{actor} shares invitation to {actor}")
    var cloudAgentSharesInvitationToEdgeAgent = { (cloudAgent: Actor, edgeAgent: Actor) in
        try await CloudAgentWorkflow.sharesInvitationToEdgeAgent(cloudAgent: cloudAgent, edgeAgent: edgeAgent)
    }
    
    @Step("{actor} should have the connection status updated to '{}'")
    var cloudAgentShouldHaveTheConnectionStatusUpdatedToConnectionResponseSent = { (cloudAgent: Actor, state: String) in
        try await CloudAgentWorkflow.shouldHaveTheConnectionStatusUpdated(cloudAgent: cloudAgent, expectedState: .ConnectionResponseSent)
    }
}
