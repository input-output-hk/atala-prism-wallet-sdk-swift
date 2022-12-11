import Combine
import DIDCommxSwift
import Domain
import Foundation

final class UnpackOperation: OnUnpackResult {
    private let didcomm: DIDCommProtocol
    private let castor: Castor
    private var published = CurrentValueSubject<Domain.Message?, Error>(nil)
    private var cancellable: AnyCancellable?

    init(didcomm: DIDCommProtocol, castor: Castor) {
        self.didcomm = didcomm
        self.castor = castor
    }

    func unpackEncrypted(messageString: String) async throws -> Domain.Message {
        let status = didcomm.unpack(
            msg: messageString,
            options: .init(expectDecryptByAllKeys: false, unwrapReWrappingForward: false),
            cb: self
        )

        switch status {
        case.success:
            return try await withCheckedThrowingContinuation { [weak self] continuation in
                guard let self else { return }
                self.cancellable = self.published
                    .drop(while: { $0 == nil })
                    .first()
                    .sink(receiveCompletion: {
                        switch $0 {
                        case .finished:
                            break
                        case let .failure(error):
                            continuation.resume(throwing: error)
                        }
                    }, receiveValue: {
                        guard let result = $0 else { return }
                        continuation.resume(returning: result)
                    })
            }
        case .error:
            throw MercuryError.unknowPackingMessageError
        }
    }

    func success(result: DIDCommxSwift.Message, metadata: DIDCommxSwift.UnpackMetadata) {
        do {
            let message: Domain.Message = try result.toDomain(castor: castor)
            published.send(message)
        } catch {
            published.send(completion: .failure(error))
        }
    }

    func error(err: DIDCommxSwift.ErrorKind, msg: String) {
        published.send(completion: .failure(MercuryError.didcommError(msg: msg)))
    }
}