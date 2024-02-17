import SwiftUI
import UIKit

struct WordsTextFieldView: UIViewRepresentable {
    enum Key {
        case backspace
        case enter
    }

    let placeholder: String
    @Binding var text: String
    let keyPressedAction: (Key) -> Void

    func makeCoordinator() -> TextFieldUIKitViewCoordinator {
        return TextFieldUIKitViewCoordinator(text: $text, keyPressed: keyPressedAction)
    }

    func makeUIView(context: Context) -> UITextField {
        context.coordinator.textField.placeholder = placeholder
        return context.coordinator.textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
}

class TextFieldUIKitViewCoordinator: NSObject {
    let textField: UITextField
    @Binding var text: String
    let keyPressed: (WordsTextFieldView.Key) -> Void

    init(text: Binding<String>, keyPressed: @escaping (WordsTextFieldView.Key) -> Void) {
        _text = text
        self.keyPressed = keyPressed
        textField = TextField(keyPressed: keyPressed)
        super.init()
        textField.delegate = self
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
    }

    private class TextField: UITextField {
        let keyPressed: (WordsTextFieldView.Key) -> Void

        init(keyPressed: @escaping (WordsTextFieldView.Key) -> Void) {
            self.keyPressed = keyPressed
            super.init(frame: .zero)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func deleteBackward() {
            super.deleteBackward()
            keyPressed(.backspace)
        }
    }
}

extension TextFieldUIKitViewCoordinator: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard text != textField.text else { return }
        text = textField.text ?? ""
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard string.isEmpty else {
            return string.rangeOfCharacter(
                from: CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ ").inverted
            ) == nil
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        keyPressed(.enter)
        return false
    }
}
