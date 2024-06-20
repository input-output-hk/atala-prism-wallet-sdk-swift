import Domain
import Foundation

struct EdgeAgentDerivationPath {
    enum KeyPurpose: Int {
        case master = 1
        case issuing = 2
        case keyAgreement = 3
        case authentication = 4
        case revocation = 5
        case capabilityInvocation = 6
        case capabilityDelegation = 7
    }
    let walletPurpose: Int
    let didMethod: Int
    let didIndex: Int
    let keyPurpose: Int
    let keyIndex: Int

    init(walletPurpose: Int = 29, didMethod: Int = 29, didIndex: Int = 0, keyPurpose: KeyPurpose, keyIndex: Int) {
        self.walletPurpose = walletPurpose
        self.didMethod = didMethod
        self.didIndex = didIndex
        self.keyPurpose = keyPurpose.rawValue
        self.keyIndex = keyIndex
    }

    var derivationPath: DerivationPath {
        .init(axis: [
            .hardened(walletPurpose),
            .hardened(didMethod),
            .hardened(didIndex),
            .hardened(keyPurpose),
            .hardened(keyIndex),
        ])
    }
}
