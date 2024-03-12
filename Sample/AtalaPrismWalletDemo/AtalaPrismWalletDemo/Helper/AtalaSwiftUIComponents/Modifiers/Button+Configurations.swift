import SwiftUI

struct AtalaPrimeButtonViewModifier: ViewModifier {
    @Environment(\.isEnabled) var isEnabled: Bool
    @Environment(\.isLoading) var isLoading: Bool

    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .frame(height: 45)
            .background((isEnabled || isLoading) ? Color(.red) : Color(.lightGray))
            .foregroundColor((isEnabled || isLoading) ? .white : Color(.gray))
            .accentColor((isEnabled || isLoading) ? .white : Color(.gray))
            .clipShape(Capsule())
    }
}

struct AtalaSecondaryButtonViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .frame(height: 45)
            .background(Color.white)
            .foregroundColor(Color(.red))
            .accentColor(Color(.red))
            .overlay(
                Capsule()
                    .stroke(Color(.red), lineWidth: 3)
            )
    }
}

struct AtalaPrimaryButtonConfiguration: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .modifier(AtalaPrimeButtonViewModifier())
    }
}

struct AtalaSecondaryButtonConfiguration: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .modifier(AtalaSecondaryButtonViewModifier())
    }
}

extension View {
    func primeButtonModifier() -> some View {
        modifier(AtalaPrimeButtonViewModifier())
    }

    func secondaryButtonModifier() -> some View {
        modifier(AtalaSecondaryButtonViewModifier())
    }
}

extension Button {
    func primeButtonConfiguration() -> some View {
        buttonStyle(AtalaPrimaryButtonConfiguration())
    }

    func secondaryButtonConfiguration() -> some View {
        buttonStyle(AtalaSecondaryButtonConfiguration())
    }
}
