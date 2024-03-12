import SwiftUI

struct IntrinsicContentWidthPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

extension View {
    func intrinsicContentWidth(to width: Binding<CGFloat>) -> some View {
        background(GeometryReader { geometry in
            Color.clear.preference(
                key: IntrinsicContentWidthPreferenceKey.self,
                value: geometry.size.width
            )
        })
            .onPreferenceChange(IntrinsicContentWidthPreferenceKey.self) {
                width.wrappedValue = $0
            }
    }
}

struct IntrinsicContentSizePreferenceKey: PreferenceKey {
    static let defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {
    func intrinsicContentSize(to size: Binding<CGSize>) -> some View {
        background(GeometryReader { geometry in
            Color.clear.preference(
                key: IntrinsicContentSizePreferenceKey.self,
                value: geometry.size
            )
        })
            .onPreferenceChange(IntrinsicContentSizePreferenceKey.self) {
                size.wrappedValue = $0
            }
    }
}
