import SwiftUI

private struct RoundedRectBorderWithText: ViewModifier {
    let text: String
    let borderColor: Color

    func body(content: Content) -> some View {
        content
            .background(
                border.overlay(
                    Text(text)
                        .font(.footnote)
                        .bold()
                        .foregroundColor(.gray)
                        .background(Color(.white))
                        .padding(.leading, 16)
                        .padding(.top, -7),
                    alignment: .topLeading
                )
            )
    }

    var border: some View {
        RoundedRectangle(cornerRadius: 10)
            .strokeBorder(
                borderColor,
                lineWidth: 1
            )
    }
}

extension View {
    func roundedRectBorderWithText(
        _ text: String,
        borderColor: Color = Color(.gray).opacity(0.7)
    ) -> some View {
        modifier(RoundedRectBorderWithText(text: text, borderColor: borderColor))
    }
}
