import Foundation

extension Array {
    func zipped() -> [(Int, Element)] {
        [(Int, Element)](zip(indices, self))
    }
}
