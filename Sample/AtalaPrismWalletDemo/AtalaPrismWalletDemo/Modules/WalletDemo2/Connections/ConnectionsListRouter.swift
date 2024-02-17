import SwiftUI

struct ConnectionsListRouterImpl: ConnectionsListRouter {
    let container: DIContainer

    func routeToAddNewConnection() -> some View {
#if targetEnvironment(simulator)
        AddNewContactBuilder().build(component: .init(
            container: container,
            token: nil
        ))
#else
        QRCodeScannerBuilder().build(component: .init(container: container))
#endif
    }
}
