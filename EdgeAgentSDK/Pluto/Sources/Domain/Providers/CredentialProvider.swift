import Combine
import Domain
import Foundation

protocol CredentialProvider {
    func getAll() -> AnyPublisher<[StorableCredential], Error>
    func getCredential(id: String) -> AnyPublisher<StorableCredential?, Error>
    func getBySchema(schema: String) -> AnyPublisher<[StorableCredential], Error>
    // TODO: Other filtering options
//    func getAllFor(contexts: [String]) -> AnyPublisher<[VerifiableCredential], Error>
//    func getAllFor(types: [String]) -> AnyPublisher<[VerifiableCredential], Error>
//    func getAllFor(issuer: DID) -> AnyPublisher<[VerifiableCredential], Error>
//    func getAllIssuedBetweenDates(From: Date, to: Date) -> AnyPublisher<[VerifiableCredential], Error>
//    func getAllExpiringBetweenDates(From: Date, to: Date) -> AnyPublisher<[VerifiableCredential], Error>
//    func getAllExpired() -> AnyPublisher<[VerifiableCredential], Error>
//    func getAllValid() -> AnyPublisher<[VerifiableCredential], Error>
}
