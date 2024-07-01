import Foundation

/// The `StorableKey` protocol defines a cryptographic key that can be stored persistently.
public protocol StorableKey {
    /// The key identifier
    var identifier: String { get set }
    
    /// An identifier used for restoring the key.
    var restorationIdentifier: String { get }

    /// The raw data representation of the key, suitable for storage.
    var storableData: Data { get }
    
    /// Indexation of the key is useful to keep track of a derivation index
    @available(*, deprecated, renamed: "derivationPath", message: "Use derivationPath instead this property will be removed on a future version")
    var index: Int? { get }

    /// Derivation path used for this key is useful to keep track of a derivation index
    var queryDerivationPath: String? { get }
}

/// Extension of the `Key` protocol to provide additional functionality related to storage.
public extension Key {
    /// A boolean value indicating whether the key can be stored persistently.
    var isStorable: Bool { self is StorableKey }

    /// Returns this key as a `StorableKey`, or `nil` if the key cannot be stored.
    var storable: StorableKey? { self as? StorableKey }
}
