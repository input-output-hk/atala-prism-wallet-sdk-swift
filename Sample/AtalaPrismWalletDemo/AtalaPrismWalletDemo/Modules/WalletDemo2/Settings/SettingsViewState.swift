import Foundation

struct SettingsViewState {
    enum Menu: String, Identifiable {
        case backup = "Backup"
        case dids = "DIDs"
        case mediator = "Mediator"

        var id: String {
            self.rawValue
        }
    }
}
