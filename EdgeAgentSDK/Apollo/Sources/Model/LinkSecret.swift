import AnoncredsSwift
import Domain
import Foundation

struct LinkSecret: Key {
    let keyType = "LinkSecret"
    let keySpecifications = [String : String]()
    let raw: Data
    var identifier = "linkSecret"
    var size: Int { raw.count }

    let anoncred: AnoncredsSwift.LinkSecret

    init(string: String) throws {
        self.anoncred = try AnoncredsSwift.LinkSecret.newFromValue(valueString: string)
        guard let strData = string.data(using: .utf8) else {
            throw CommonError.invalidCoding(message: "Could not encode LinkSecret in Data")
        }
        self.raw = strData
    }

    init(data: Data) throws {
        guard let str = String(data: data, encoding: .utf8) else {
            throw CommonError.invalidCoding(message: "Could not encode LinkSecret in String")
        }
        self.anoncred = try AnoncredsSwift.LinkSecret.newFromValue(valueString: str)
        self.raw = data
    }

    init() throws {
        let anoncred = Prover().createLinkSecret()
        self.anoncred = anoncred
        guard let strData = try anoncred.getValue().data(using: .utf8) else {
            throw CommonError.invalidCoding(message: "Could not encode LinkSecret in Data")
        }
        self.raw = strData
    }
}

extension LinkSecret: KeychainStorableKey {
    var restorationIdentifier: String { "linkSecret+key" }
    var storableData: Data { raw }
    var index: Int? { nil }
    var queryDerivationPath: String? { nil }
    var type: Domain.KeychainStorableKeyProperties.KeyAlgorithm { .rawKey }
    var keyClass: Domain.KeychainStorableKeyProperties.KeyType { .privateKey }
    var accessiblity: Domain.KeychainStorableKeyProperties.Accessability? { .firstUnlock(deviceOnly: true) }
    var synchronizable: Bool { false }
}
