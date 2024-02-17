import SwiftUI

struct InsertCodeView: View {
    @Binding var textField: String
    let loading: Bool
    let doneAction: () -> Void
    let cancelAction: () -> Void

    var body: some View {
        VStack(spacing: 35) {
            VStack(spacing: 0) {
                Image("img_qr_red")
                Text("connections_enter_code".localize())
                    .font(.title2)
                    .fontWeight(.heavy)
            }

            TextField("", text: $textField)
                .padding()
                .roundedRectBorderWithText("connections_enter_code_placeholder".localize())

            HStack {
                AtalaButton(
                    configuration: .secondary,
                    action: {
                        self.cancelAction()
                    },
                    label: {
                        Text("cancel".localize())
                    }
                )

                AtalaButton(
                    loading: loading,
                    action: {
                        self.doneAction()
                    },
                    label: {
                        Text("confirm".localize())
                    }
                )
            }
        }
        .padding(24)
    }
}

struct InsertCodeView_Previews: PreviewProvider {
    static var previews: some View {
        InsertCodeView(
            textField: .constant(""),
            loading: false,
            doneAction: {},
            cancelAction: {}
        )
    }
}
