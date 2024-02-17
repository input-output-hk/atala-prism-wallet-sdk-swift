import SwiftUI

protocol Builder {
    associatedtype Component
    associatedtype BuilderView: View

    func build(component: Component) -> BuilderView
}

extension Builder {
    func buildVC(component: Component) -> UIViewController {
        UIHostingController(rootView: build(component: component))
    }
}

extension Builder where Component: ComponentContainer {
    func getViewModel<ViewModel>(component: Component, failsafe: () -> ViewModel) -> ViewModel {
        guard let viewModel = component.container.resolve(type: ViewModel.self) else {
            let viewModel = failsafe()
            component.container.register(type: ViewModel.self, component: viewModel)
            return viewModel
        }
        return viewModel
    }
}
