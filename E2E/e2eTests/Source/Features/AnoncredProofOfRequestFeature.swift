import XCTest

final class AnoncredProofOfRequestFeature: Feature {
    override func title() -> String {
        "Provide anonymous proof of request"
    }
    
    override func description() -> String {
        "The Edge Agent should provide anonymous proof to Cloud Agent"
    }
    
    func testRespondToProofOfRequest() async throws {
        currentScenario = Scenario("Respond to anonymous request proof")
            .given("Cloud Agent is connected to Edge Agent")
            .and("Edge Agent has '1' anonymous credentials issued by Cloud Agent")
            .when("Cloud Agent asks for anonymous present-proof")
            .and("Edge Agent sends the present-proof")
            .then("Cloud Agent should see the present-proof is verified")
    }
}
