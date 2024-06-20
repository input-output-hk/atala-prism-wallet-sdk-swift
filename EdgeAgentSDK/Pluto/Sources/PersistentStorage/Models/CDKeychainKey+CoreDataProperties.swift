import CoreData
import Foundation

extension CDKeychainKey {
    @nonobjc class func createFetchRequest() -> NSFetchRequest<CDKeychainKey> {
        return NSFetchRequest<CDKeychainKey>(entityName: "CDKeychainKey")
    }

    @NSManaged var tag: String?
    @NSManaged var service: String
    @NSManaged var type: String
    @NSManaged var algorithm: String
}
