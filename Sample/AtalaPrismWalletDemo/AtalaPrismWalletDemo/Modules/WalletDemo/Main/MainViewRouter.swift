import SwiftUI
import Domain
import PrismAgent

final class MainViewRouterImpl: MainViewRouter {
    let agent: PrismAgent

    init() {
        let did = try! DID(string: "did:peer:2.Ez6LScc4S6tTSf5PnB7tWAna8Ee2aL7z2nRgo6aCHQwLds3m4.Vz6MktCyutFBcZcAWBnE2shqqUQDyRdnvcwqMTPqWsGHMnHyT.SeyJpZCI6Im5ldy1pZCIsInQiOiJkbSIsInMiOiJodHRwOi8vcm9vdHNpZC1tZWRpYXRvcjo4MDAwIiwiYSI6WyJkaWRjb21tL3YyIl19")

        self.agent = PrismAgent(mediatorServiceEnpoint: did)
    }

    func routeToDashboard() -> some View {
        let container = DIContainerImpl()
        container.register(type: PrismAgent.self, component: agent)
        return DashboardBuilder().build(component: .init(container: container))
    }
}