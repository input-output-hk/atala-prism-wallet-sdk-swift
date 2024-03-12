import SwiftUI

protocol RequestDetailViewModel: ObservableObject {
    var request: RequestDetailViewState.RequestType { get }

    func acceptProposal(id: String)
    func refuseProposal(id: String)
    func acceptPresentation(id: String, credentialId: String)
    func refusePresentation(id: String)
}

protocol RequestDetailViewRouter {
    associatedtype CredentialDetailV: View

    func routeToCredentialDetail() -> CredentialDetailV
}

//struct RequestDetailView<ViewModel: RequestDetailViewModel, Router: RequestDetailViewRouter>: View {
//    @StateObject var viewModel: ViewModel
//    let router: Router
//
//    var body: some View {
//    }
//}
