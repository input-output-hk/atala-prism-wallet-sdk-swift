import Foundation

struct AddNewContactState {
    enum AddContacFlowStep {
        case getCode
        case checkDuplication
        case alreadyConnected
        case confirmConnection
        case error(DisplayError)
    }

    struct Contact {
        enum Icon {
            case data(Data)
            case name(String)
        }

        let text: String
    }
}
