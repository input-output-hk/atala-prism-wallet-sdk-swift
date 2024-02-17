import SwiftUI

protocol Main2ViewRouter {
    associatedtype MediatorV: View
    associatedtype DidsV: View
    associatedtype ConnectionsV: View
    associatedtype MessagesV: View
    associatedtype CredentialsV: View
    associatedtype SettingsV: View

    func routeToMediator() -> MediatorV
    func routeToDids() -> DidsV
    func routeToConnections() -> ConnectionsV
    func routeToMessages() -> MessagesV
    func routeToCredentials() -> CredentialsV
    func routeToSettings() -> SettingsV
}

struct Main2View<Router: Main2ViewRouter>: View {
    let router: Router

    var body: some View {
        TabView {
            router.routeToConnections()
                .tabItem {
                    Text("Connections")
                }

            router.routeToMessages()
                .tabItem {
                    Text("Messages")
                }

            router.routeToCredentials()
                .tabItem {
                    Text("Credentials")
                }

            router.routeToSettings()
                .tabItem {
                    Text("Settings")
                }
        }
    }
}
