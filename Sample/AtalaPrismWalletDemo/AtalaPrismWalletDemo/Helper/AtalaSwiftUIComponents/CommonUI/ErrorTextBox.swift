import SwiftUI

struct ErrorTextBox: View {
    let errorText: String

    var body: some View {
        HStack(spacing: 16) {
            Image("ico_err")
                .resizable()
                .frame(width: 14, height: 14)
            Text(errorText)
                .font(.caption)
                .bold()
                .multilineTextAlignment(.leading)
                .foregroundColor(Color(.red))
            Spacer()
        }
        .padding()
        .background(Color(.red).opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
