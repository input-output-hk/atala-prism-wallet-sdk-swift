import Foundation

extension URL: ExpressibleByStringLiteral {
    public init(stringLiteral value: StaticString) {
        guard let url = URL(string: "\(value)") else {
            assert(URL(string: "\(value)") == nil, "Invalid literal URL")
            self = URL(fileURLWithPath: "")
            return
        }
        self = url
    }
}
