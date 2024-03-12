import Foundation

extension String {

    func localize() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
