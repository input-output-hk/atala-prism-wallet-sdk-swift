import Domain
import Foundation

extension JWTCredential: ExportableCredential {
    var exporting: Data {
        (try? jwtString.tryToData()) ?? Data()
    }
    
    var restorationType: String { "jwt" }
}
