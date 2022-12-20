import Combine
import Domain
import Foundation
import PrismAgent

final class AddNewContactViewModelImpl: AddNewContactViewModel {
    @Published var flowStep: AddNewContactState.AddContacFlowStep
    @Published var code = ""
    @Published var dismiss = false
    @Published var dismissRoot = false
    @Published var loading = false
    @Published var contactInfo: AddNewContactState.Contact?
    private let agent: PrismAgent
    private var parsed: PrismAgent.InvitationType?
    private var cancellables = Set<AnyCancellable>()

    init(
        token: String = "",
        agent: PrismAgent
    ) {
        code = token
        self.agent = agent
        flowStep = token.isEmpty ? .getCode : .getInfo
        if token.isEmpty {
            // Due to not being able to paste on rosetta simulator from M1
            code = "https://domain.com/path?_oob=eyJpZCI6ImUzNzZlZGYyLWVmNmQtNDk4ZS1hMTk3LWMwZTI2MGQxNTA2OCIsInR5cGUiOiJodHRwczovL2RpZGNvbW0ub3JnL291dC1vZi1iYW5kLzIuMC9pbnZpdGF0aW9uIiwiZnJvbSI6ImRpZDpwZWVyOjIuRXo2TFNoQUFxY1ZlZXRQNmlrdHk1bXl5OFFweE5wVlk3NEF0YUZuVmFrOFRwYnRkSy5WejZNa2dlYUVWZ0FVSHoyQWczaUZLRDIxMjZTR0tERnpIS28zSEFxYmM4eExOM1paLlNleUowSWpvaVpHMGlMQ0p6SWpvaWFIUjBjRG92TDJodmMzUXVaRzlqYTJWeUxtbHVkR1Z5Ym1Gc09qZ3dPREF2Wkdsa1kyOXRiU0lzSW5JaU9sdGRMQ0poSWpwYkltUnBaR052YlcwdmRqSWlYWDAiLCJib2R5Ijp7ImdvYWxfY29kZSI6ImNvbm5lY3QiLCJnb2FsIjoiRXN0YWJsaXNoIGEgdHJ1c3QgY29ubmVjdGlvbiBiZXR3ZWVuIHR3byBwZWVycyIsImFjY2VwdCI6W119fQ=="
        }
    }

    func getTokenInfo() {
        guard !loading else { return }
        loading = true
        Task {
            do {
                let parsed = try await agent.parseInvitation(str: code)
                await MainActor.run {
                    switch parsed {
                    case let .onboardingPrism(onboarding):
                        self.contactInfo = .init(text: onboarding.from)
                    case let .onboardingDIDComm(invitation):
                        self.contactInfo = .init(text: invitation.from)
                    }
                    self.parsed = parsed
                    flowStep = .confirmConnection
                    loading = false
                }
            } catch {
                self.flowStep = .error(DisplayErrorState(error: error))
            }
        }
    }

    func addContact() {
        guard !code.isEmpty, !loading, let parsed else { return }
        loading = true
        Task {
            do {
                switch parsed {
                case let .onboardingPrism(onboarding):
                    try await agent.acceptPrismInvitation(invitation: onboarding)
                case let .onboardingDIDComm(invitation):
                    try await agent.acceptDIDCommInvitation(invitation: invitation)
                }
                await MainActor.run {
                    loading = false
                    dismiss = true
                    dismissRoot = true
                }
            } catch let error as MercuryError {
                switch error {
                case let .urlSessionError(statusCode, error, msg):
                    print("HTTP Error: \(statusCode)")
                case let .didcommError(msg):
                    print("Error: \(msg)")
                default:
                    break
                }
                await MainActor.run {
                    self.flowStep = .error(DisplayErrorState(error: error))
                }
                print("Error: \(error.localizedDescription)")
            } catch {
                await MainActor.run {
                    self.flowStep = .error(DisplayErrorState(error: error))
                    print(error.localizedDescription)
                }
            }
        }
    }
}
