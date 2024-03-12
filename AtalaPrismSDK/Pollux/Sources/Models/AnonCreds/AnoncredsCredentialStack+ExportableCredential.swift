import Domain
import Foundation

extension AnoncredsCredentialStack: ExportableCredential {
    var exporting: Data { (try? JSONEncoder().encode(credential)) ?? Data() }
    
    var restorationType: String { "anoncred" }
}
