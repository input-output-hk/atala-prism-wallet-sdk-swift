import Combine
import CoreData
import Domain

struct CDKeyDAO: CoreDataDAO {
    typealias CoreDataObject = CDKey
    let keychainDao: CDKeychainKeyDAO
    let databaseDAO: CDDatabaseKeyDAO
    let readContext: NSManagedObjectContext
    let writeContext: NSManagedObjectContext
    let identifierKey: String? = "identifier"

    init(
        keychain: KeychainStore & KeychainProvider,
        keychainService: String,
        readContext: NSManagedObjectContext,
        writeContext: NSManagedObjectContext
    ) {
        self.keychainDao = CDKeychainKeyDAO(
            keychain: keychain,
            keychainService: keychainService,
            readContext: readContext,
            writeContext: writeContext
        )
        self.databaseDAO = CDDatabaseKeyDAO(
            readContext: readContext,
            writeContext: writeContext
        )
        self.readContext = readContext
        self.writeContext = writeContext
    }
}

extension CDKey {
    func parseToStorableKey(keychain: KeychainProvider) throws -> StorableKey {
        switch self {
        case let keychainKey as CDKeychainKey:
            guard
                let algortihm = KeychainStorableKeyProperties.KeyAlgorithm(rawValue: keychainKey.algorithm),
                let keyType = KeychainStorableKeyProperties.KeyType(rawValue: keychainKey.type)
            else {
                // TODO: Update this error
                throw PlutoError.algorithmOrKeyTypeNotValid(algorithm: keychainKey.algorithm, keyType: keychainKey.type)
            }
            let keyData = try keychain.getKey(
                service: keychainKey.service,
                account: keychainKey.identifier,
                tag: keychainKey.tag,
                algorithm: algortihm,
                type: keyType
            )

            return StorableKeyModel(
                identifier: keychainKey.identifier,
                restorationIdentifier: keychainKey.restorationIdentifier,
                storableData: keyData,
                index: keychainKey.index?.intValue, 
                queryDerivationPath: keychainKey.derivationPath
            )
        case let databaseKey as CDDatabaseKey:
            return StorableKeyModel(
                identifier: databaseKey.identifier,
                restorationIdentifier: databaseKey.restorationIdentifier,
                storableData: databaseKey.storableData,
                index: databaseKey.index?.intValue,
                queryDerivationPath: databaseKey.derivationPath
            )
        default:
            throw UnknownError.somethingWentWrongError(
                customMessage: "This should never happen it a key always have a type of CDKeychainKey or CDDatabaseKey",
                underlyingErrors: nil
            )
        }
    }
}
