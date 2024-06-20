import Foundation

/// `DerivationPath` is a structure that represents the path for key derivation in hierarchical deterministic (HD) wallets.
public struct DerivationPath {

    public enum Axis: RawRepresentable {
        case normal(Int)
        case hardened(Int)

        public init?(rawValue: Int) {
            if rawValue < 0 {
                return nil
            }
            if rawValue >= 0 && rawValue < (1 << 31) {
                self = .normal(rawValue)
            } else if rawValue >= (1 << 31) && rawValue < (1 << 32) {
                self = .hardened(rawValue - (1 << 31))
            } else {
                return nil
            }
        }

        public var rawValue: Int {
            switch self {
            case .normal(let int):
                return int
            case .hardened(let int):
                return int
            }
        }

        public var string: String {
            switch self {
            case .normal(let int):
                return "\(int)"
            case .hardened(let int):
                return "\(int)'"
            }
        }
    }

    /// The index of the key in the path.
    @available(*, deprecated, renamed: "axis", message: "Use axis instead this property will be removed on a future version")
    public let index: Int

    public let axis: [Axis]

    /// Creates a new `DerivationPath` instance from a given index.
    /// - Parameter index: The index of the key in the path.
    @available(*, deprecated, renamed: "init(axis:)", message: "Use init(axis:) instead this method will be removed on a future version")
    public init(index: Int) {
        self.index = index
        self.axis = [.hardened(index), .hardened(0), .hardened(0)]
    }

    public init(axis: [Axis] = [.hardened(0), .hardened(0), .hardened(0)]) {
        self.axis = axis
        self.index = axis.first?.rawValue ?? 0
    }

    /// Creates a new `DerivationPath` instance from a path string.
    /// - Parameter string: A string representation of the path.
    /// - Throws: `CommonError.invalidRegex` if the path string cannot be parsed.
    public init(string: String) throws {
        let pattern = "^m(\\/\\d+'?)+$"
        let validationRegex = try NSRegularExpression(pattern: pattern, options: [])
        guard !validationRegex.matches(
            in: string,
            options: [],
            range: NSRange(location: 0, length: string.utf16.count)
        ).isEmpty else { throw CommonError.invalidRegex(regex: pattern, invalid: string) }

        let parsingRegex = try NSRegularExpression(pattern: "\\d+", options: [])
        let matches = parsingRegex.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))

        guard let firstMatch = matches.first else {
            throw CommonError.invalidRegex(regex: pattern, invalid: string)
        }
        let range = Range(firstMatch.range, in: string)!
        guard let index = Int(String(string[range])) else {
            throw CommonError.invalidRegex(regex: pattern, invalid: string)
        }
        self.index = index
        self.axis = try matches.map {
            let range = Range($0.range, in: string)!
            guard
                let index = Int(String(string[range]))
            else {
                throw CommonError.invalidRegex(regex: pattern, invalid: string)
            }
            return Axis.hardened(index)
        }
    }

    /// Returns a string representation of this `DerivationPath`.
    /// - Returns: A string in the format of "m/<index>'/0'/0'".
    public func keyPathString() -> String {
        return (["m"] + axis.map(\.string)).joined(separator: "/")
    }
}

/// `DerivableKey` is a protocol that defines functionality for keys that can be derived using a `DerivationPath`.
public protocol DerivableKey {
    func deriveKey(withPublicKey otherPublicKey: PublicKey, salt: Data?) throws -> Data
    func deriveKey(usingDerivationPath path: DerivationPath) throws -> Key
}

/// Extension to add derivable functionality to `Key`.
public extension Key {
    /// A Boolean value indicating whether the key is derivable.
    var isDerivable: Bool { self is DerivableKey }

    /// Returns the derivable representation of the key.
    var derivable: DerivableKey? { self as? DerivableKey }
}
