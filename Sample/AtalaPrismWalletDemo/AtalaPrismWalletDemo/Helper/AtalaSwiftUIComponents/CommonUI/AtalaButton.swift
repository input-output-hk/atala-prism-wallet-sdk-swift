import SwiftUI

struct AtalaButton<Label: View>: View {
    enum Configuration {
        case primary
        case secondary
    }

    let configuration: Configuration
    let loading: Bool
    let action: () -> Void
    @ViewBuilder var label: () -> Label

    init(
        configuration: Configuration = .primary,
        loading: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.configuration = configuration
        self.loading = loading
        self.action = action
        self.label = label
    }

    @Environment(\.isEnabled) var isEnabled: Bool

    var body: some View {
        let button = Button(action: action, label: {
            HStack(spacing: 6) {
                label()
                if loading {
                    ProgressView()
                        .progressViewStyle(
                            CircularProgressViewStyle(
                                tint: .white
                            )
                        )
                }
            }
        })
        if configuration == .primary {
            button
                .primeButtonConfiguration()
                .environment(\.isLoading, loading)
        } else {
            button
                .secondaryButtonConfiguration()
                .environment(\.isLoading, loading)
        }
    }
}

struct AtalaButton_Previews: PreviewProvider {
    static var previews: some View {
        AtalaButton(loading: true, action: {}, label: {
            Text("Something")
        })
            .disabled(true)
    }
}
