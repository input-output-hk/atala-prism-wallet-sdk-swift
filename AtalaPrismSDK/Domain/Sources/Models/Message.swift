import Foundation

/// The `Message` struct represents a DIDComm message, which is used for secure, decentralized communication in the Atala PRISM architecture. A `Message` object includes information about the sender, recipient, message body, and other metadata. `Message` objects are typically exchanged between DID controllers using the `Mercury` building block.
public struct Message: Identifiable, Hashable {
    /// The direction of the message (sent or received).
    public enum Direction: String, Codable {
        case sent
        case received
    }

    /// The unique identifier of the message.
    public let id: String

    /// The PIURI associated with the message.
    public let piuri: String

    /// The DID of the sender, if known.
    public let from: DID?

    /// The DID of the recipient, if known.
    public let to: DID?

    /// The `from_prior` value associated with the message, if any.
    public let fromPrior: String?

    /// The message body, as raw data.
    public let body: Data

    /// Additional headers to include in the message.
    public let extraHeaders: [String: String]

    /// The time the message was created.
    public let createdTime: Date

    /// The time at which the message will expire.
    public let expiresTimePlus: Date?

    /// Descriptors for any attachments included in the message.
    public let attachments: [AttachmentDescriptor]

    /// The `thid` value associated with the message, if any.
    public let thid: String?

    /// The `pthid` value associated with the message, if any.
    public let pthid: String?

    /// The `ack` values associated with the message, if any.
    public let ack: [String]

    /// The direction of the message (sent or received).
    public let direction: Direction

    /// Initializes a new `Message` object with the specified properties.
    /// - Parameters:
    ///   - id: The unique identifier of the message. If not provided, a random UUID will be used.
    ///   - piuri: The PIURI associated with the message.
    ///   - from: The DID of the sender, if known.
    ///   - to: The DID of the recipient, if known.
    ///   - fromPrior: The `from_prior` value associated with the message, if any.
    ///   - body: The message body, as raw data.
    ///   - extraHeaders: Additional headers to include in the message.
    ///   - createdTime: The time the message was created. Defaults to the current time.
    ///   - expiresTimePlus: The time at which the message will expire. Defaults to the current time plus 30 seconds.
    ///   - attachments: Descriptors for any attachments included in the message.
    ///   - thid: The `thid` value associated with the message, if any.
    ///   - pthid: The `pthid` value associated with the message, if any.
    ///   - ack: The `ack` values associated with the message, if any.
    ///   - direction: The direction of the message (sent or received).
    public init(
        id: String = UUID().uuidString,
        piuri: String,
        from: DID? = nil,
        to: DID? = nil,
        fromPrior: String? = nil,
        body: Data,
        extraHeaders: [String : String] = [:],
        createdTime: Date = Date(),
        expiresTimePlus: Date? = nil,
        attachments: [AttachmentDescriptor] = [],
        thid: String? = nil,
        pthid: String? = nil,
        ack: [String] = [],
        direction: Direction = .received
    ) {
        self.id = id
        self.piuri = piuri
        self.from = from
        self.to = to
        self.fromPrior = fromPrior
        self.body = body
        self.extraHeaders = extraHeaders
        self.createdTime = createdTime
        self.expiresTimePlus = expiresTimePlus
        self.attachments = attachments
        self.thid = thid
        self.pthid = pthid
        self.ack = ack
        self.direction = direction
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(body)
        hasher.combine(piuri)
    }

    public static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
        && lhs.to == rhs.to
        && lhs.from == rhs.from
        && lhs.piuri == rhs.piuri
        && lhs.body == rhs.body
    }
}
