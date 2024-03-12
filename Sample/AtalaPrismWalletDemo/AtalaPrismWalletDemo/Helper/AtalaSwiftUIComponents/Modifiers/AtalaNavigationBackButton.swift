import SwiftUI

struct AtalaNavigationBackButtonModifier<Trailing: View>: ViewModifier {
    let tintColor: Color
    let divider: Bool
    @ViewBuilder var title: () -> Text
    @ViewBuilder var trailing: () -> Trailing
    @Environment(\.presentationMode) var presentationMode

    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            if divider {
                Divider()
            }
            content
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: leadingView, trailing: trailing())
    }

    private var leadingView: some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Image("ico_backarrow")
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(tintColor)
            })
            title()
                .font(.system(size: 18))
                .foregroundColor(tintColor)
        }
    }
}

extension View {
    func atalaNavigationBackButton(title: String = "", divider: Bool = true) -> some View {
        atalaNavigationBackButton(title: title, divider: divider) {
            EmptyView()
        }
    }

    func atalaNavigationBackButton<Trailing: View>(
        title: String = "",
        divider: Bool = true,
        tintColor: Color = Color(.black),
        @ViewBuilder trailing: @escaping () -> Trailing
    ) -> some View {
        modifier(AtalaNavigationBackButtonModifier(
            tintColor: tintColor,
            divider: divider,
            title: {
                Text(title)
            }, trailing: trailing
        ))
    }
}
