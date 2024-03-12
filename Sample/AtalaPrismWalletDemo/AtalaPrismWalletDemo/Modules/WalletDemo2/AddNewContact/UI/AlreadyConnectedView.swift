import SwiftUI

struct AlreadyConnectedView: View {
    let name: String
    let doneAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("contacts_add_new_already_connected_caption".localize())
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Text(name)
                        .font(.title3)
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                }
            }

            Divider()

            AtalaButton {
                self.doneAction()
            } label: {
                Text("ok".localize())
            }
        }
        .padding(24)
    }
}

struct AlreadyConnectedView_Previews: PreviewProvider {
    static var previews: some View {
        AlreadyConnectedView(
            name: "Atala KYC"
        ) {}
    }
}
