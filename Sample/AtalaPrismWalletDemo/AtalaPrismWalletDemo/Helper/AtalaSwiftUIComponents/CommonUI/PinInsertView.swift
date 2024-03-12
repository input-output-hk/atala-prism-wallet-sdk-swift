import Combine
import SwiftUI

struct PinInsertView: View {
    let title: String?
    var centered = false
    @Binding var code: String
    @State private var isVisible = false
    @State private var isFocused = false

    private let maxLength = 4

    var body: some View {
        VStack(alignment: centered ? .center : .leading) {
            if title != nil {
                Text(title ?? "")
                    .font(.body)
                    .foregroundColor(Color(UIColor.gray))
            }
            HStack(spacing: 10) {
                ZStack {
                    pinDots
                    backgroundField
                }
                Button(action: {
                    isVisible.toggle()
                }, label: {
                    Image(isVisible ? "ico_visibility_off" : "ico_visibility_on")
                })
            }
            .frame(maxWidth: .infinity, alignment: centered ? .center : .leading)
        }
    }

    private var pinDots: some View {
        HStack(spacing: 10) {
            ForEach(0 ..< maxLength) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .foregroundColor(Color(UIColor.lightGray))
                        .frame(width: 44, height: 44)

                    Text(self.getDigits(at: index))
                        .font(.title)
                }
            }
        }
    }

    private var backgroundField: some View {
        TextField("", text: $code, onEditingChanged: { editingChanged in
            isFocused = editingChanged
        })
            .accentColor(.clear)
            .foregroundColor(.clear)
            .frame(width: 210, height: 60)
            .keyboardType(.numberPad)
            .onReceive(Just(code)) { _ in limitText(maxLength) }
    }

    // Function to keep text length in limits
    func limitText(_ upper: Int) {
        if code.count > upper {
            code = String(code.prefix(upper))
        }
    }

    private func getDigits(at index: Int) -> String {
        if index > code.count {
            return ""
        }
        if index == code.count {
            return isFocused ? "|" : ""
        }

        return isVisible ? code.digits[index].numberString : "•"
    }
}

private extension String {
    var digits: [Int] {
        var result = [Int]()

        for char in self {
            if let number = Int(String(char)) {
                result.append(number)
            }
        }

        return result
    }
}

private extension Int {
    var numberString: String {
        guard self < 10 else { return "0" }

        return String(self)
    }
}

struct PinInsertView_Previews: PreviewProvider {
    @State static var code = ""
    static var previews: some View {
        PinInsertView(title: "TITLE", code: $code)
    }
}
