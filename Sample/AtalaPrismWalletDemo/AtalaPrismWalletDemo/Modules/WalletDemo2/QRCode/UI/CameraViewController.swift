import AVFoundation
import Combine
import UIKit

protocol CameraViewDelegate: AVCaptureMetadataOutputObjectsDelegate {
    func didFail(error: Error)
}

final class CameraViewController: UIViewController {
    enum CameraError: Error {
        case invalidInput
        case invalidOutput
    }

    let codeTypes: [AVMetadataObject.ObjectType]
    let videoCaptureDevice = AVCaptureDevice.default(for: .video)
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    weak var delegate: CameraViewDelegate?
    var cancellables = Set<AnyCancellable>()

    init(codeTypes: [AVMetadataObject.ObjectType], delegate: CameraViewDelegate? = nil) {
        self.codeTypes = codeTypes
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default
            .publisher(for: Notification.Name("UIDeviceOrientationDidChangeNotification"))
            .sink { [weak self] _ in
                self?.updateOrientation()
            }
            .store(in: &cancellables)

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = videoCaptureDevice else {
            return
        }

        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            delegate?.didFail(error: CameraError.invalidInput)
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = codeTypes
        } else {
            delegate?.didFail(error: CameraError.invalidOutput)
            return
        }

        let gesture = UITapGestureRecognizer(target: self, action: #selector(tap(sender:)))
        view.addGestureRecognizer(gesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if previewLayer == nil {
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        }
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateOrientation()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }

    override func viewWillLayoutSubviews() {
        previewLayer?.frame = view.layer.bounds
    }

    @objc func tap(sender: UITapGestureRecognizer) {
        guard let touchView = sender.view else { return }
        if sender.state == .ended {
            let screenSize = touchView.bounds.size
            let touchPoint = sender.location(in: touchView)
            let xPoint = touchPoint.y / screenSize.height
            let yPoint = 1.0 - touchPoint.x / screenSize.width
            let focusPoint = CGPoint(x: xPoint, y: yPoint)

            focus(point: focusPoint)
        }
    }

    private func updateOrientation() {
        guard let connection = captureSession.connections.last, connection.isVideoOrientationSupported else { return }
        view.window?.windowScene.map {
            connection.videoOrientation = AVCaptureVideoOrientation(
                rawValue: $0.interfaceOrientation.rawValue
            ) ?? .portrait
        }
    }

    private func focus(point: CGPoint) {
        guard let device = videoCaptureDevice else { return }

        do {
            try device.lockForConfiguration()
        } catch {
            return
        }

        device.focusPointOfInterest = point
        device.focusMode = .continuousAutoFocus
        device.exposurePointOfInterest = point
        device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
        device.unlockForConfiguration()
    }
}
