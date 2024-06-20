import Domain
import Foundation

struct StorableKeyModel: StorableKey {
    var identifier: String
    let restorationIdentifier: String
    let storableData: Data
    let index: Int?
    let queryDerivationPath: String?
}
