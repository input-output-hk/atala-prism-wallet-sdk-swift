//
//  WordTagEditable.swift
//  prism-ios-wallet
//
//  Created by Goncalo Frade IOHK on 28/09/2021.
//

import SwiftUI

struct WordTagEditable: View {
    let words: [String]
    let selectedToDelete: Int?
    let spacing: CGFloat
    let onDelete: (Int) -> Void

    @State private var intrinsicWidth: CGFloat = 0

    var body: some View {
        // ScrollView(.vertical, showsIndicators: true) {
        VStack(alignment: .leading) {
            let rows = calculateRows(words: words)
            ForEach(Array(rows.enumerated()), id: \.offset) { row in
                HStack {
                    ForEach(Array(row.element.enumerated()), id: \.offset) {
                        TagView(
                            index: $0.element.index,
                            word: $0.element.word,
                            isSelected: $0.element.index == selectedToDelete,
                            onDelete: onDelete
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .intrinsicContentWidth(to: $intrinsicWidth)
        // }
        // .fixedSize(horizontal: false, vertical: true)
    }

    private func calculateRows(words: [String]) -> [[(index: Int, word: String)]] {
        words.enumerated().reduce([[(Int, String)]]()) { rows, word in
            var newRows = rows
            if var row = rows.last, calculateRowSize(words: row) <= intrinsicWidth {
                if calculateRowSize(words: row + [word]) <= intrinsicWidth {
                    newRows.removeLast()
                    row.append(word)
                    newRows.append(row)
                    return newRows
                }
            }
            newRows.append([word])
            return newRows
        }
    }

    private func calculateRowSize(words: [(Int, String)]) -> CGFloat {
        words.reduce(CGFloat(0)) {
            let view = TagView(
                index: $1.0,
                word: $1.1,
                isSelected: $1.0 == selectedToDelete
            ) { _ in }
            return $0 + UIHostingController(rootView: view)
                .view
                .intrinsicContentSize
                .width
        } + spacing * CGFloat(words.count)
    }
}

private struct TagView: View {
    let index: Int
    let word: String
    let isSelected: Bool
    let onDelete: (Int) -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text("\(index + 1). \(word)")
                .bold()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .foregroundColor(Color(.red))
                .padding(.leading)
                .padding(.vertical, 2)
                .fixedSize(horizontal: false, vertical: true)
            Image("ico_delete_x")
                .onTapGesture {
                    onDelete(index)
                }
                .padding(.trailing)
        }
        .background(isSelected ? Color(.red).opacity(0.6) : Color(.red).opacity(0.3))
        .clipShape(Capsule())
    }
}
