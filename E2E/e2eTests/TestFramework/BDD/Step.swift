
import Foundation

@propertyWrapper
class Step<T> {
    let file: StaticString
    let line: UInt
    var definition: String
    var wrappedValue: (T) async throws -> ()

    init(wrappedValue: @escaping (T) async throws -> (), _ definition: String, file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
        self.wrappedValue = wrappedValue
        self.definition = definition
        StepRegistry.addStep(self)
    }
}
