import SwiftUI

struct DeleteView<Content: View, Info: View>: View {
    private let deleteAction: () -> Void
    private let showInfoView: Bool
    private var loading: Bool

    @ViewBuilder private var content: () -> Content
    @ViewBuilder private var info: () -> Info

    @Environment(\.presentationMode) var presentationMode

    init(
        showInfoView: Bool = true,
        loading: Bool = false,
        deleteAction: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder info: @escaping () -> Info
    ) {
        self.deleteAction = deleteAction
        self.content = content
        self.info = info
        self.showInfoView = showInfoView
        self.loading = loading
    }

    var body: some View {
        VStack(spacing: 15) {
            VStack(spacing: 9) {
                Image("icon_delete")
                VStack(spacing: 4) {
                    Text("contacts_delete_confrimation_title".localize())
                        .font(.body)
                        .fontWeight(.heavy)
                        .bold()
                        .foregroundColor(Color(.red))
                    Text("contacts_delete_confrimation_message".localize())
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
            Divider()
            content()
            Divider()
            if showInfoView {
                info()
                Divider()
            }
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("cancel".localize())
                        .frame(maxWidth: .infinity)
                        .secondaryButtonModifier()
                })

                AtalaButton(loading: self.loading) {
                    self.deleteAction()
                } label: {
                    Text("delete".localize())
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
    }
}

struct DeleteView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteView(showInfoView: true) {} content: {
            HStack(spacing: 16) {
                Image("ico_placeholder_credential")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text("Atala KYC")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .bold()
                    .foregroundColor(.black)
                Spacer()
            }
        } info: {
            VStack(alignment: .leading, spacing: 9) {
                Text("contacts_delete_description".localize())
                    .font(.body)
                    .foregroundColor(.gray)
                VStack(alignment: .leading, spacing: 6) {
                    Text(". ID Credential")
                        .bold()
                        .font(.body)
                        .foregroundColor(.black)
                    Text(". University Credential")
                        .bold()
                        .font(.body)
                        .foregroundColor(.black)
                }
            }
        }
    }
}
