import SwiftUI

struct DisablePreferenceKey: PreferenceKey {
    static let defaultValue = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        let next = nextValue()
        if next != value {
            value = next
        }
    }
}

private struct CommitDisablePreferenceModifier: ViewModifier {
    @Environment(\.isEnabled) var isEnabled

    func body(content: Content) -> some View {
        content
            .preference(key: DisablePreferenceKey.self, value: isEnabled)
    }
}

extension View {
    func disablePreference(_ toBinder: Binding<Bool>) -> some View {
        onPreferenceChange(DisablePreferenceKey.self, perform: { value in
            DispatchQueue.main.async {
                toBinder.wrappedValue = !value
            }
        })
    }

    func commitDisablePreference() -> some View {
        modifier(CommitDisablePreferenceModifier())
    }
}
