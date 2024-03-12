import SwiftUI

struct WordTagsGrid: View {
    private struct WidthPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = .zero
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
    }

    let words: [String]
    let onDelete: (Int) -> Void

    private let gridSpacing: CGFloat = 16
    @State private var itemsWidth: CGFloat = 1

    @Environment(\.editMode) var editMode

    var isEditing: Bool { editMode?.wrappedValue == .active }

    var body: some View {
        LazyVGrid(
            columns: grids,
            spacing: 20
        ) {
            ForEach(Array(words.enumerated()), id: \.offset) {
                tagView(
                    index: $0.offset,
                    word: $0.element,
                    width: itemsWidth,
                    editing: editMode?.wrappedValue == .active
                )
            }
        }
        .background(GeometryReader { geometry in
            Color.clear
                .preference(key: WidthPreferenceKey.self, value: geometry.size.width)
        })
        .onPreferenceChange(WidthPreferenceKey.self, perform: { value in
            let div = value - (gridSpacing * 2)
            if div >= 0 {
                itemsWidth = div / 3
            }
        })
    }

    private var grids: [GridItem] {
        if isEditing {
            return [
                GridItem(.flexible(), spacing: gridSpacing),
                GridItem(.flexible(), spacing: gridSpacing),
                GridItem(.flexible())
            ]
        } else {
            return [
                GridItem(.fixed(itemsWidth), spacing: gridSpacing),
                GridItem(.fixed(itemsWidth), spacing: gridSpacing),
                GridItem(.fixed(itemsWidth))
            ]
        }
    }

    @ViewBuilder
    private func tagView(index: Int, word: String, width: CGFloat, editing: Bool) -> some View {
        HStack(spacing: 6) {
            Text("\(index + 1). \(word)")
                .bold()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .foregroundColor(Color(.red))
                .padding(editing ? .leading : .horizontal)
                .padding(.vertical, 2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            if editing {
                Image("ico_delete_x")
                    .onTapGesture {
                        onDelete(index)
                    }
                    .padding(.trailing)
            }
        }
        .frame(width: width > 0 ? width : 0, height: 30)
        .background(Color(.red).opacity(0.1))
        .clipShape(Capsule())
    }
}
