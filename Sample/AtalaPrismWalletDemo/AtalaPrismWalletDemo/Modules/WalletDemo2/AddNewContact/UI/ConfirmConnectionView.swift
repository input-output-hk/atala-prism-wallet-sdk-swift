import SwiftUI

struct ConfirmConnectionView: View {
    let name: String
    let loading: Bool
    let doneAction: () -> Void
    let cancelAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("contacts_add_new_confirm_connection_caption".localize())
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Text(name)
                        .font(.title3)
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                }
                Spacer()
            }

            Divider()

            HStack {
                AtalaButton(configuration: .secondary) {
                    self.cancelAction()
                } label: {
                    Text("cancel".localize())
                }

                AtalaButton(loading: loading) {
                    self.doneAction()
                } label: {
                    Text("contacts_add_new_confirm_connection_confirm_bt".localize())
                }
            }
        }
        .padding(24)
    }
}

struct ConfirmConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmConnectionView(
            name: "Atala KYC",
            loading: false
        ) {} cancelAction: {}
    }
}
