import SwiftUI

struct QRCodeScannerComponent: ComponentContainer {
    let container: DIContainer
}

struct QRCodeScannerBuilder: Builder {
    func build(component: QRCodeScannerComponent) -> some View {
        let viewModel = getViewModel(component: component) {
            QRCodeScannerViewModelImpl()
        }
        let router = QRCodeScannerRouterImpl(container: component.container)
        return QRCodeScannerView(router: router, viewModel: viewModel)
            .onDisappear {
                component.container.unregister(type: QRCodeScannerViewModelImpl.self)
            }
    }
}
