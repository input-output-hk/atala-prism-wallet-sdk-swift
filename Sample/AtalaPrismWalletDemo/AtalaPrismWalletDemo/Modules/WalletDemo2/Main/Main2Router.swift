import Builders
import Combine
import Domain
import PrismAgent
import SwiftUI

final class Main2RouterImpl: Main2ViewRouter {
    let container: DIContainer = DIContainerImpl()

    init() {
        let apollo = ApolloBuilder().build()
        let castor = CastorBuilder(apollo: apollo).build()
        let pluto = PlutoBuilder().build()
        let pollux = PolluxBuilder(pluto: pluto).build()
        let mercury = MercuryBuilder(
            castor: castor,
            secretsStream: createSecretsStream(
                keyRestoration: apollo,
                pluto: pluto,
                castor: castor
            )
        ).build()

        let mnemonics = ["pig", "fork", "educate", "gun", "entire", "scatter", "satoshi", "laugh", "project", "buffalo", "race", "enroll", "shiver", "theme", "similar", "thought", "prepare", "velvet", "wild", "mention", "jelly", "match", "document", "rapid"]

        let seed = try! apollo.createSeed(mnemonics: mnemonics, passphrase: "")

        let agent = PrismAgent(
            apollo: apollo,
            castor: castor,
            pluto: pluto,
            pollux: pollux,
            mercury: mercury,
            seed: seed
        )
        container.register(type: Apollo.self, component: apollo)
        container.register(type: Castor.self, component: castor)
        container.register(type: Pluto.self, component: pluto)
        container.register(type: Pollux.self, component: pollux)
        container.register(type: Mercury.self, component: mercury)
        container.register(type: PrismAgent.self, component: agent)
    }

    func routeToMediator() -> some View {
        let viewModel = MediatorViewModelImpl(
            castor: container.resolve(type: Castor.self)!,
            pluto: container.resolve(type: Pluto.self)!,
            agent: container.resolve(type: PrismAgent.self)!
        )
        return MediatorPageView(viewModel: viewModel)
    }

    func routeToDids() -> some View {
        let viewModel = DIDListViewModelImpl(
            pluto: container.resolve(type: Pluto.self)!,
            agent: container.resolve(type: PrismAgent.self)!
        )

        return DIDListView(viewModel: viewModel)
    }

    func routeToConnections() -> some View {
        let viewModel = ConnectionsListViewModelImpl(
            castor: container.resolve(type: Castor.self)!,
            pluto: container.resolve(type: Pluto.self)!,
            agent: container.resolve(type: PrismAgent.self)!
        )

        return ConnectionsListView(
            router: ConnectionsListRouterImpl(container: container),
            viewModel: viewModel
        )
    }

    func routeToMessages() -> some View {
        let viewModel = MessagesListViewModelImpl(
            agent: container.resolve(type: PrismAgent.self)!
        )

        return MessagesListView(
            viewModel: viewModel,
            router: MessageListRouterImpl(container: container)
        )
    }

    func routeToCredentials() -> some View {
        let viewModel = CredentialListViewModelImpl(
            agent: container.resolve(type: PrismAgent.self)!,
            pluto: container.resolve(type: Pluto.self)!
        )

        return CredentialListView(
            viewModel: viewModel,
            router: CredentialListRouterImpl(container: container)
        )
    }

    func routeToSettings() -> some View {
        let router = SettingsViewRouterImpl(container: container)
        return SettingsView(viewModel: SettingsViewModelImpl(), router: router)
    }
}

private func createSecretsStream(
    keyRestoration: KeyRestoration,
    pluto: Pluto,
    castor: Castor
) -> AnyPublisher<[Secret], Error> {
    pluto.getAllKeys()
        .first()
        .flatMap { keys in
            Future {
                let privateKeys = await keys.asyncMap {
                    try? await keyRestoration.restorePrivateKey($0)
                }.compactMap { $0 }
                return try parsePrivateKeys(
                    privateKeys: privateKeys,
                    castor: castor
                )
            }
        }
        .eraseToAnyPublisher()
}

private func parsePrivateKeys(
    privateKeys: [PrivateKey],
    castor: Castor
) throws -> [Domain.Secret] {
    return try privateKeys
        .map { $0 as? (PrivateKey & ExportableKey & StorableKey) }
        .compactMap { $0 }
        .map { privateKey in
        return privateKey
    }
    .map { privateKey in
        try parseToSecret(
            privateKey: privateKey,
            identifier: privateKey.identifier
        )
    }
}

private func parseToSecret(privateKey: PrivateKey & ExportableKey, identifier: String) throws -> Domain.Secret {
    let jwk = privateKey.jwk
    guard
        let dataJson = try? JSONEncoder().encode(jwk),
        let stringJson = String(data: dataJson, encoding: .utf8)
    else {
        throw CommonError.invalidCoding(message: "Could not encode privateKey.jwk")
    }
    return .init(
        id: identifier,
        type: .jsonWebKey2020,
        secretMaterial: .jwk(value: stringJson)
    )
}
