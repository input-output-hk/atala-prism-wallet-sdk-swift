import SwiftUI

protocol BackupViewModel: ObservableObject {
    var backupString: String { get }
    var recoverWallet: String { get set }
    var dismiss: Bool { get }
    func done()
}

struct BackupView<ViewModel: BackupViewModel>: View {
    @StateObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 8) {
            Text("Backup this wallet string")
                .bold()
            Text(viewModel.backupString)
                .textSelection(.enabled)
                .lineLimit(1)
                .truncationMode(.middle)
            Divider()
            TextField("Backup String", text: $viewModel.recoverWallet)
            AtalaButton(
                configuration: .primary,
                action: {
                    viewModel.done()
                },
                label: {
                    Text("Done".localize())
                }
            )
        }
        .padding()
        .onChange(of: viewModel.dismiss, perform: { value in
            if value {
                dismiss()
            }
        })
    }
}
