import Combine
import Foundation

final class QRCodeScannerViewModelImpl: QRCodeScannerViewModel {
    @Published var token: String?
    @Published var showInfo = false
    @Published var dismiss = false

    func qrCodeFound(_ qrCode: String) {
        guard !showInfo, !dismiss else { return }
        token = qrCode
        showInfo = true
    }

    func cameraError(_ error: Error) {}
}
