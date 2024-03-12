import Combine
import CoreData
import Domain

extension CDMessageDAO: MessageStore {
    func addMessages(messages: [(Message, Message.Direction)]) -> AnyPublisher<Void, Error> {
        messages
            .publisher
            .flatMap {
                self.addMessage(msg: $0.0, direction: $0.1)
            }
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    func addMessage(msg: Message, direction: Message.Direction) -> AnyPublisher<Void, Error> {
        return pairDAO
            .fetchController(
                predicate: NSPredicate(
                    format: "(holderDID.did == %@) OR (holderDID.did == %@) OR (did == %@) OR (did == %@)",
                    msg.from?.string ?? "",
                    msg.to?.string ?? "",
                    msg.from?.string ?? "",
                    msg.to?.string ?? ""
                ),
                context: writeContext
            )
            .first()
            .map { $0.first }
            .flatMap { pair in
                self.updateOrCreate(
                    msg.id,
                    context: writeContext
                ) { cdobj, _ in
                    try cdobj.fromDomain(msg: msg, direction: direction, pair: pair)
                }
            }
            .map { _ in }
            .eraseToAnyPublisher()
    }

    func removeMessage(id: String) -> AnyPublisher<Void, Error> {
        deleteByIDsPublisher([id], context: writeContext)
    }

    func removeAll() -> AnyPublisher<Void, Error> {
        deleteAllPublisher(context: writeContext)
    }
}

private extension CDMessage {
    func fromDomain(msg: Message, direction: Message.Direction, pair: CDDIDPair?) throws {
        self.messageId = msg.id
        self.from = msg.from?.string
        self.to = msg.to?.string
        self.type = msg.piuri
        self.dataJson = try JSONEncoder().encode(CodableMessage(message: msg))
        self.createdTime = msg.createdTime
        self.pair = pair
        self.direction = direction.rawValue
    }
}
