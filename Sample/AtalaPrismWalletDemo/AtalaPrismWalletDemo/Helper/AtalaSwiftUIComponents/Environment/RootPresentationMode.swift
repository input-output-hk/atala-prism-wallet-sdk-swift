import SwiftUI

struct RootPresentationModeKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(Bool())
}

extension EnvironmentValues {
    var rootPresentationMode: Binding<Bool> {
        get { return self[RootPresentationModeKey.self] }
        set { self[RootPresentationModeKey.self] = newValue }
    }
}
