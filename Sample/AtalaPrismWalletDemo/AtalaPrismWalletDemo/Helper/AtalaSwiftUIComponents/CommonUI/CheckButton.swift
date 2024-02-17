import SwiftUI

struct CheckButton: View {
    @Binding var isSelected: Bool

    var body: some View {
        Button(action: {
            withAnimation {
                self.isSelected = !isSelected
            }
        }, label: {
            if isSelected {
                Image("ico_check_on")
                    .resizable()
            } else {
                Image("ico_check_off")
                    .resizable()
            }
        })
        .frame(width: 40, height: 40)
    }
}
