import SwiftUI

protocol QRCodeScannerViewModel: ObservableObject {
    var token: String? { get }
    var showInfo: Bool { get set }
    var dismiss: Bool { get set }
    func qrCodeFound(_ qrCode: String)
    func cameraError(_ error: Error)
}

protocol QRCodeScannerRouter {
    associatedtype AddNewContact: View
    func routeToAddNewContact(token: String?) -> AddNewContact
}

struct QRCodeScannerView<
    ViewModel: QRCodeScannerViewModel,
    Router: QRCodeScannerRouter
>: View {
    let router: Router
    @StateObject var viewModel: ViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            ZStack {
                QRScannerView {
                    self.viewModel.qrCodeFound($0)
                } onCameraError: {
                    self.viewModel.cameraError($0)
                }
                LinearGradient(
                    gradient: Gradient(colors: [
                        .black.opacity(0.6),
                        .clear,
                        .clear,
                        .black.opacity(0.6)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()

            VStack {
                HStack {
                    Button {
                        self.viewModel.dismiss = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(.horizontal, 26)
            .padding(.vertical)
        }
        .preferredColorScheme(.dark)
        .clearFullScreenCover(
            isPresented: $viewModel.showInfo
        ) {
            LazyView {
                router.routeToAddNewContact(token: viewModel.token)
                    .environment(\.rootPresentationMode, $viewModel.dismiss)
            }
        }
        .onChange(of: viewModel.dismiss, perform: { value in
            if value {
                self.presentationMode.wrappedValue.dismiss()
            }
        })
    }
}

struct QRCodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeScannerView(router: MockRouter(), viewModel: MockViewModel())
    }
}

private class MockViewModel: QRCodeScannerViewModel {
    var token: String? = ""

    var showInfo = false

    var dismiss = false

    func qrCodeFound(_ qrCode: String) {}

    func cameraError(_ error: Error) {}
}

private struct MockRouter: QRCodeScannerRouter {
    func routeToAddNewContact(token: String?) -> some View {
        Text("token")
            .foregroundColor(.white)
    }
}
