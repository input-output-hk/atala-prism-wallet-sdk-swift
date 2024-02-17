import UIKit

struct NavigationUtil {
    static func popToRootView(
        navigationVC: UINavigationController,
        animated: Bool = true
    ) {
        navigationVC.popToRootViewController(animated: animated)
    }

    static func findNavigationControllerFromRoot() -> UINavigationController? {
        guard
            let rootVc = UIApplication
            .shared
            .windows
            .filter({ $0.isKeyWindow })
            .first?
            .rootViewController
        else { return nil }

        return findNavigationController(viewController: rootVc)
    }

    static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else {
            return nil
        }

        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }

        for childViewController in viewController.children {
            return findNavigationController(viewController: childViewController)
        }

        return nil
    }

    static func findTopViewController() -> UIViewController? {
        guard
            let rootVc = UIApplication
            .shared
            .windows
            .filter({ $0.isKeyWindow })
            .first?
            .rootViewController
        else { return nil }

        var topVC = rootVc

        while let presentedVC = topVC.presentedViewController {
            topVC = presentedVC
        }

        return topVC
    }
}
