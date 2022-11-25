import Core
import Domain
import Foundation

extension AttachmentDescriptor {
    static func build<T: Encodable>(
        id: String = UUID().uuidString,
        payload: T,
        mediaType: String? = "application/json"
    ) throws -> AttachmentDescriptor {
        let encoded = try JSONEncoder().encode(payload).base64UrlEncodedString()
        return AttachmentDescriptor(
            id: id,
            mediaType: mediaType,
            data: AttachmentBase64(base64: encoded)
        )
    }
}
