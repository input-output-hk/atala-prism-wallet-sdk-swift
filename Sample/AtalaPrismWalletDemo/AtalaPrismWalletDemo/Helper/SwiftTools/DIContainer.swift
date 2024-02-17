import Foundation

protocol DIContainer {
    func register<Component>(type: Component.Type, component: Any)
    func unregister<Component>(type: Component.Type)
    func resolve<Component>(type: Component.Type) -> Component?
}

final class DIContainerImpl: DIContainer {
    private var components: [String: Any] = [:]

    func register<Component>(type: Component.Type, component: Any) {
        components["\(type)"] = component
    }

    func unregister<Component>(type: Component.Type) {
        components["\(type)"] = nil
    }

    func resolve<Component>(type: Component.Type) -> Component? {
        return components["\(type)"] as? Component
    }
}
