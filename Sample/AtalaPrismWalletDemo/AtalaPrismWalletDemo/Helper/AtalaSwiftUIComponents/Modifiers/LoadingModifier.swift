import SwiftUI

private struct LoadingModifier: ViewModifier {
    @Binding var enabled: Bool

    func body(content: Content) -> some View {
        content
            .clearFullScreenCover(isPresented: $enabled) {
                ProgressView("loading_title".localize())
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(alignment: .center)
                    .padding()
                    .background(
                        Color(.lightGray)
                            .opacity(0.8)
                            .blur(radius: 2.0, opaque: true)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    )
                    .onAppear {
                        UIView.setAnimationsEnabled(true)
                    }
                    .onDisappear {
                        UIView.setAnimationsEnabled(true)
                    }
            }
    }
}

extension View {
    func addLoading(enabled: Bool) -> some View {
        modifier(LoadingModifier(
            enabled: .init(
                get: {
                    if enabled {}
                    return enabled
                }, set: { _ in }
            )
        ))
    }
}
