import SwiftUI

struct EmptyNavigationLink<Destination: View>: View {
    let isActive: Binding<Bool>
    @ViewBuilder var destination: () -> Destination

    var body: some View {
        NavigationLink(
            isActive: isActive
        ) {
            self.destination()
        } label: {
            EmptyView()
        }
    }
}
