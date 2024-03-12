import SwiftUI

struct FlowSuccessfulView: View {
    let imageName: String
    let titleText: String?
    let subtitleText: String?
    let infoText: String?
    let buttonText: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Spacer()
            Image(imageName)
            if let text = titleText {
                Text(text)
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
            }
            if let text = subtitleText {
                Text(text)
                    .font(.title2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
            }
            if let text = infoText {
                Text(text)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: {
                self.action()
            }, label: {
                Text(buttonText)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .primeButtonModifier()
            })
        }
        .padding()
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

struct FlowSuccessfulView_Previews: PreviewProvider {
    static var previews: some View {
        FlowSuccessfulView(
            imageName: "img_success",
            titleText: "Welcome!",
            subtitleText: "Your account has been successfuly restored",
            infoText: nil,
            buttonText: "Continue"
        ) {}
    }
}
