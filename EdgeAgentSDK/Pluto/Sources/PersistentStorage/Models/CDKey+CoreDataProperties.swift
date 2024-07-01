import CoreData
import Foundation

extension CDKey {
    @nonobjc class func createFetchRequest() -> NSFetchRequest<CDKey> {
        return NSFetchRequest<CDKey>(entityName: "CDKey")
    }

    @NSManaged var identifier: String
    @NSManaged var restorationIdentifier: String
    @NSManaged var index: NSNumber?
    @NSManaged var derivationPath: String?
    @NSManaged var did: CDDIDPrivateKey?
}

extension CDKey: Identifiable {
    var id: String {
        identifier
    }
}
