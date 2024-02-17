import SwiftUI

struct SearchBoxView: View {
    let placeholder: String
    @Binding var searchString: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField(placeholder, text: $searchString)
            Spacer()
        }
        .padding(.horizontal)
        .frame(height: 40)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(
                    Color(.gray),
                    lineWidth: 1
                )
                .background(Color.white)
        )
    }
}

struct SearchBoxView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBoxView(
            placeholder: "connections_search_contacts".localize(),
            searchString: .constant("")
        )
        .padding()
    }
}
