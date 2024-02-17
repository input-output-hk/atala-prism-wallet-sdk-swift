//
//  HyperlinkText.swift
//  prism-ios-wallet
//
//  Created by Goncalo Frade IOHK on 26/09/2021.
//

import SwiftUI

struct HyperlinkTextView: View {
    let text: String
    let selectionText: String
    @ViewBuilder let textBuilder: (String) -> Text
    @ViewBuilder let hyperlinkBuilder: (String) -> Text
    let action: () -> Void

    init(
        text: String,
        selectionText: String,
        @ViewBuilder textBuilder: @escaping (String) -> Text,
        @ViewBuilder hyperlinkBuilder: @escaping (String) -> Text,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.selectionText = selectionText
        self.textBuilder = textBuilder
        self.hyperlinkBuilder = hyperlinkBuilder
        self.action = action
    }

    var body: some View {
        HyperlinkView(
            text: text,
            selectionText: selectionText,
            textBuilder: textBuilder
        ) {
            hyperlinkBuilder($0)
                .onTapGesture {
                    self.action()
                }
        }
    }
}

struct HyperlinkNavigationView<Destination: View>: View {
    let text: String
    let selectionText: String
    @ViewBuilder let destination: () -> Destination
    @ViewBuilder let textBuilder: (String) -> Text
    @ViewBuilder let hyperlinkBuilder: (String) -> Text

    init(
        text: String,
        selectionText: String,
        @ViewBuilder destination: @escaping () -> Destination,
        @ViewBuilder textBuilder: @escaping (String) -> Text,
        @ViewBuilder hyperlinkBuilder: @escaping (String) -> Text
    ) {
        self.text = text
        self.selectionText = selectionText
        self.destination = destination
        self.textBuilder = textBuilder
        self.hyperlinkBuilder = hyperlinkBuilder
    }

    var body: some View {
        HyperlinkView(
            text: text,
            selectionText: selectionText,
            textBuilder: textBuilder
        ) { text in
            NavigationLink(
                destination: destination(),
                label: {
                    hyperlinkBuilder(text)
                }
            )
        }
    }
}

struct HyperlinkSheetView<Destination: View>: View {
    let text: String
    let selectionText: String
    @ViewBuilder let destination: () -> Destination
    @ViewBuilder let textBuilder: (String) -> Text
    @ViewBuilder let hyperlinkBuilder: (String) -> Text

    @State private var presentingSheet = false

    init(
        text: String,
        selectionText: String,
        @ViewBuilder destination: @escaping () -> Destination,
        @ViewBuilder textBuilder: @escaping (String) -> Text,
        @ViewBuilder hyperlinkBuilder: @escaping (String) -> Text
    ) {
        self.text = text
        self.selectionText = selectionText
        self.destination = destination
        self.textBuilder = textBuilder
        self.hyperlinkBuilder = hyperlinkBuilder
    }

    var body: some View {
        HyperlinkView(
            text: text,
            selectionText: selectionText,
            textBuilder: textBuilder
        ) {
            hyperlinkBuilder($0)
                .onTapGesture {
                    self.presentingSheet = true
                }
                .sheet(isPresented: $presentingSheet, content: destination)
        }
    }
}

struct HyperlinkView<HyperlinkView: View>: View {
    let text: String
    let selectionText: String
    @ViewBuilder let textBuilder: (String) -> Text
    @ViewBuilder let hyperlinkBuilder: (String) -> HyperlinkView

    private let separatedStrings: [String]

    init(
        text: String,
        selectionText: String,
        @ViewBuilder textBuilder: @escaping (String) -> Text,
        @ViewBuilder hyperlinkBuilder: @escaping (String) -> HyperlinkView
    ) {
        self.text = text
        self.selectionText = selectionText
        self.textBuilder = textBuilder
        self.hyperlinkBuilder = hyperlinkBuilder
        separatedStrings = text.components(separatedBy: selectionText)
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(self.separatedStrings.enumerated()), id: \.offset) {
                textBuilder($0.element)
                if $0.offset != self.separatedStrings.count - 1 {
                    hyperlinkBuilder(selectionText)
                }
            }
        }
    }
}

struct HyperlinkText_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack {
                HyperlinkTextView(
                    text: "Hello, World",
                    selectionText: "World",
                    textBuilder: {
                        Text($0)
                            .font(.body)
                            .foregroundColor(.black)
                    },
                    hyperlinkBuilder: {
                        Text($0)
                            .font(.body)
                            .bold()
                            .foregroundColor(Color(.red))
                    },
                    action: {}
                )

                HyperlinkNavigationView(
                    text: "Hello, World",
                    selectionText: "World",
                    destination: {
                        Text("Next")
                    },
                    textBuilder: {
                        Text($0)
                            .font(.body)
                            .foregroundColor(.black)
                    },
                    hyperlinkBuilder: {
                        Text($0)
                            .font(.body)
                            .bold()
                            .foregroundColor(Color(.red))
                    }
                )

                HyperlinkSheetView(
                    text: "Hello, World",
                    selectionText: "World",
                    destination: {
                        Text("Next")
                    },
                    textBuilder: {
                        Text($0)
                            .font(.body)
                            .foregroundColor(.black)
                    },
                    hyperlinkBuilder: {
                        Text($0)
                            .font(.body)
                            .bold()
                            .foregroundColor(Color(.red))
                    }
                )
            }
        }
    }
}
