import SwiftUI

struct QRCodeScannerRouterImpl: QRCodeScannerRouter {
    let container: DIContainer

    func routeToAddNewContact(token: String?) -> some View {
        AddNewContactBuilder().build(
            component: .init(
                container: container,
                token: token
            )
        )
    }
}
