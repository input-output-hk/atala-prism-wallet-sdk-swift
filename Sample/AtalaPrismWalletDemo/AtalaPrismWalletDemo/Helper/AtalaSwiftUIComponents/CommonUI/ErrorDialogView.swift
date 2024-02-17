import SwiftUI

protocol DisplayError: Error {
    var message: String { get }
    var debugMessage: String? { get }
}

struct ErrorDialogView: View {
    // The idea in here is to be able to nil the error
    // once it is presented. It seems more streamlined.
    // But open to discussion.
    @Binding var error: DisplayError?
    private let errorMessage: String
    private let debugMessage: String?
    private let action: () -> Void

    init(
        error: Binding<DisplayError?>,
        action: @escaping () -> Void
    ) {
        _error = error
        errorMessage = error.wrappedValue?.message ?? ""
        debugMessage = error.wrappedValue?.debugMessage
        self.action = action
    }

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Image("img_verifyId_error")
                Text("error".localize())
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                Text(errorMessage)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)
                if let debugError = debugMessage {
                    Text("DEBUG:\n\(debugError)")
                        .font(.system(size: 16, weight: .regular))
                        .multilineTextAlignment(.leading)
                }
            }
            AtalaButton {
                self.error = nil
                self.action()
            } label: {
                Text("accept".localize())
            }
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
    }
}

private struct MockError: DisplayError {
    var message: String = "Something went wrong."
    var debugMessage: String?
}

struct ErrorDialogView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorDialogView(error: .constant(MockError())) {}
    }
}

extension View {
    func showErrorDialog(error: Binding<DisplayError?>) -> some View {
        clearFullScreenCover(
            isPresented: .init(get: {
                error.wrappedValue != nil
            }, set: { _ in })) {
            ErrorDialogView(error: error) {}
        }
    }
}
