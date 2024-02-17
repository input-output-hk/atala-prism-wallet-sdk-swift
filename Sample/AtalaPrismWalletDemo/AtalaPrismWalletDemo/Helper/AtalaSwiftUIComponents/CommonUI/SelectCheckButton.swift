import SwiftUI

struct SelectCheckButton: View {
    @Binding var isSelected: Bool

    var body: some View {
        Button(action: {
            withAnimation {
                self.isSelected = !isSelected
            }
        }, label: {
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .foregroundColor(Color(.red))
            } else {
                Circle()
                    .strokeBorder(
                        Color(.gray),
                        lineWidth: 1,
                        antialiased: true
                    )
            }
        })
            .frame(width: 24, height: 24)
    }
}

struct SelectCheckButtonPreviewView: PreviewProvider {
    static var previews: some View {
        SelectCheckButton(isSelected: .constant(false))
    }
}
