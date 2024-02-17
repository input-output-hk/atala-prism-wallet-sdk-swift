import SwiftUI

struct PrimeButtonNavidationLink<Destination: View>: View {
    let text: String
    let destination: Destination

    var body: some View {
        NavigationLink(
            destination: destination,
            label: {
                Text(text)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .primeButtonModifier()
            }
        )
    }
}

struct SecondaryButtonNavidationLink<Destination: View>: View {
    let text: String
    let destination: Destination

    var body: some View {
        NavigationLink(
            destination: destination,
            label: {
                Text(text)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .secondaryButtonModifier()
            }
        )
    }
}
