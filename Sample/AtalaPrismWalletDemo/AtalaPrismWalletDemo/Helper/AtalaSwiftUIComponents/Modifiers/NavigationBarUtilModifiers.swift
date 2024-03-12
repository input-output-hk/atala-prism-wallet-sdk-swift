import SwiftUI

private struct NavigationControllerIntrospect: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<NavigationControllerIntrospect>
    ) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: UIViewControllerRepresentableContext<NavigationControllerIntrospect>
    ) {
        guard
            let navigationContoller = uiViewController.navigationController
        else { return }
        configure(navigationContoller)
    }
}

extension View {
    func configureNavigationBar(_ configure: @escaping (UINavigationBar) -> Void) -> some View {
        modifier(NavigationConfigurationViewModifier(configure: configure))
    }
}

struct NavigationConfigurationViewModifier: ViewModifier {
    let configure: (UINavigationBar) -> Void

    func body(content: Content) -> some View {
        content.background(NavigationControllerIntrospect(configure: {
            configure($0.navigationBar)
        }))
    }
}
