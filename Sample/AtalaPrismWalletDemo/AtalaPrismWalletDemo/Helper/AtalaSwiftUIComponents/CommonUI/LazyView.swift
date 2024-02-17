import SwiftUI

struct LazyView<Content: View>: View {
    @ViewBuilder var build: () -> Content
    init(@ViewBuilder _ build: @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}
