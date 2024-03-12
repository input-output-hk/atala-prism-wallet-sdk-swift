import PrismAgent
import Foundation

struct DisplayErrorState: DisplayError {
    let message: String
    let debugMessage: String?

    init(error: Error) {
        message = "default_error_message".localize()
        debugMessage = error.localizedDescription
    }
}
