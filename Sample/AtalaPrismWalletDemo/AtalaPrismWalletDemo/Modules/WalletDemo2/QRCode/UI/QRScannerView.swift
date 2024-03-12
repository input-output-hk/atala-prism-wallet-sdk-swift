import AVFoundation
import SwiftUI

struct QRScannerView: UIViewControllerRepresentable {
    class Coordinator: NSObject, CameraViewDelegate {
        let onQRCodeFound: (String) -> Void
        let onError: (Error) -> Void

        init(
            onQRCodeFound: @escaping (String) -> Void,
            onError: @escaping (Error) -> Void
        ) {
            self.onQRCodeFound = onQRCodeFound
            self.onError = onError
        }

        func metadataOutput(
            _ output: AVCaptureMetadataOutput,
            didOutput metadataObjects: [AVMetadataObject],
            from connection: AVCaptureConnection
        ) {
            guard
                let metadataObject = metadataObjects.first,
                let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                let stringValue = readableObject.stringValue
            else { return }
            onQRCodeFound(stringValue)
        }

        func reset() {}

        func didFail(error: Error) {
            onError(error)
        }
    }

    let onQRCodeFound: (String) -> Void
    let onCameraError: (Error) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(
            onQRCodeFound: onQRCodeFound,
            onError: onCameraError
        )
    }

    func makeUIViewController(context: Context) -> CameraViewController {
        let viewController = CameraViewController(codeTypes: [.qr], delegate: context.coordinator)
        return viewController
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}
