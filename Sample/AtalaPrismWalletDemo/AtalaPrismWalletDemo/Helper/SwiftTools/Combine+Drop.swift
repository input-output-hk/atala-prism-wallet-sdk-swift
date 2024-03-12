import Combine

extension Publisher {
    func dropCast<T>(_: T.Type) -> AnyPublisher<T?, Failure> {
        map { $0 as? T }
            .drop { $0 == nil }
            .eraseToAnyPublisher()
    }

    func dropNil<T>() -> AnyPublisher<T, Failure> where Output == T? {
        drop { $0 == nil }
            .map {
                guard let value = $0 else { fatalError("This will never happen") }
                return value
            }
            .eraseToAnyPublisher()
    }
}

extension Publishers {
    struct MissingOutputError: Error {}
}

public extension Publishers.First where Failure == Error {
    func await() async throws -> Output {
        for try await output in values {
            return output
        }
        throw Publishers.MissingOutputError()
    }
}

public extension Publishers.FirstWhere where Failure == Error {
    func await() async throws -> Output {
        for try await output in values {
            return output
        }
        throw Publishers.MissingOutputError()
    }
}
