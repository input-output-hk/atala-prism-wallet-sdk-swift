import Foundation

class EdgeAgentSteps: Steps {
    @Step("{actor} sends the present-proof")
    var edgeAgentSendsThePresentProof = { (edgeAgent: Actor) in
        try await EdgeAgentWorkflow.waitForProofRequest(edgeAgent: edgeAgent)
        try await EdgeAgentWorkflow.presentProof(edgeAgent: edgeAgent)
    }
    
    @Step("{actor} has '{int}' credentials issued by {actor}")
    var edgeAgentHasCredentialsIssuedByCloudAgent = { (edgeAgent: Actor, numberOfCredentials: Int, cloudAgent: Actor) in
        try await EdgeAgentWorkflow.hasIssuedCredentials(edgeAgent: edgeAgent, numberOfCredentialsIssued: numberOfCredentials, cloudAgent: cloudAgent)
    }
    
    @Step("{actor} has '{int}' anonymous credentials issued by {actor}")
    var edgeAgentHasAnonymousCredentialsIssuedByCloudAgent = { (edgeAgent: Actor, numberOfCredentials: Int, cloudAgent: Actor) in
        try await EdgeAgentWorkflow.hasIssuedAnonymousCredentials(edgeAgent: edgeAgent, numberOfCredentialsIssued: numberOfCredentials, cloudAgent: cloudAgent)
    }
    
    @Step("{actor} accepts {int} credential offer sequentially from {actor}")
    var edgeAgentAcceptsCredentialsOfferSequentiallyFromCloudAgent = { (edgeAgent: Actor, numberOfCredentials: Int, cloudAgent: Actor) in
        var recordIdList: [String] = []
        for _ in 0..<numberOfCredentials {
            try await CloudAgentWorkflow.offersACredential(cloudAgent: cloudAgent)
            try await EdgeAgentWorkflow.waitToReceiveCredentialsOffer(edgeAgent: edgeAgent, numberOfCredentials: 1)
            try await EdgeAgentWorkflow.acceptsTheCredentialOffer(edgeAgent: edgeAgent)
            let recordId: String = try cloudAgent.recall(key: "recordId")
            try await CloudAgentWorkflow.verifyCredentialState(cloudAgent: cloudAgent, recordId: recordId, expectedState: .CredentialSent)
            recordIdList.append(recordId)
        }
        try cloudAgent.remember(key: "recordIdList", value: recordIdList)
    }
    
    @Step("{actor} accepts {int} credentials offer at once from {actor}")
    var edgeAgentAcceptsCredentialsOfferAtOnceFromCloudAgent = { (edgeAgent: Actor, numberOfCredentials: Int, cloudAgent: Actor) in
        var recordIdList: [String] = []
        for _ in 0..<numberOfCredentials {
            try await CloudAgentWorkflow.offersACredential(cloudAgent: cloudAgent)
            recordIdList.append(try cloudAgent.recall(key: "recordId"))
        }
        try cloudAgent.remember(key: "recordIdList", value: recordIdList)
        
        try await EdgeAgentWorkflow.waitToReceiveCredentialsOffer(edgeAgent: edgeAgent, numberOfCredentials: 3)
        
        for _ in 0..<numberOfCredentials {
            try await EdgeAgentWorkflow.acceptsTheCredentialOffer(edgeAgent: edgeAgent)
        }
    }
    
    @Step("{actor} should receive the credential")
    var edgeAgentShouldReceiveTheCredential = { (edgeAgent: Actor) in
        try await EdgeAgentWorkflow.waitToReceiveCredentialsOffer(edgeAgent: edgeAgent, numberOfCredentials: 1)
    }
    
    @Step("{actor} accepts the credential")
    var edgeAgentAcceptsTheCredential = { (edgeAgent: Actor) in
        try await EdgeAgentWorkflow.acceptsTheCredentialOffer(edgeAgent: edgeAgent)
    }
    
    @Step("{actor} wait to receive {int} issued credentials")
    var edgeAgentWaitToReceiveIssuedCredentials = { (edgeAgent: Actor, numberOfCredentials: Int) in
        try await EdgeAgentWorkflow.waitToReceiveIssuedCredentials(edgeAgent: edgeAgent, numberOfCredentials: numberOfCredentials)
    }
    
    @Step("{actor} process {int} issued credentials")
    var edgeAgentProcessIssuedCredentials = { (edgeAgent: Actor, numberOfCredentials: Int) in
        try await EdgeAgentWorkflow.processIssuedCredentials(edgeAgent: edgeAgent, numberOfCredentials: numberOfCredentials)
    }
    
    @Step("{actor} connects through the invite")
    var edgeAgentConnectsThroughTheInvite = { (edgeAgent: Actor) in
        try await EdgeAgentWorkflow.connectsThroughTheInvite(edgeAgent: edgeAgent)
    }
}
