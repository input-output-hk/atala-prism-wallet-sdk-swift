import Foundation

class CommonSteps: Steps {
    @Step("{actor} is dismissed")
    var actorIsDismissed = { (actor: Actor) async throws in
        try await actor.tearDown()
    }
}
