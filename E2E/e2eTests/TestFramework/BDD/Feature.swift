
import Foundation
import XCTest
import SwiftHamcrest

class Feature: XCTestCase {
    let id: String = UUID().uuidString
    var currentScenario: Scenario? = nil
    private static var scenarioEnd: Bool = false
    
    func title() -> String {
        fatalError("Set feature title")
    }

    func description() -> String {
        return ""
    }
    
    /// our lifecycle starts after xctest is ending
    override func tearDown() async throws {
        try await run()
        try await super.tearDown()
    }

    override class func tearDown() {
        let semaphore = DispatchSemaphore(value: 0)
        Task.init {
            try await TestConfiguration.shared().endCurrentFeature()
            semaphore.signal()
        }
        semaphore.wait()
        super.tearDown()
    }

    func run() async throws {
        // check if we have the scenario
        if (currentScenario == nil) {
            fatalError("""
            To run the feature you have to setup the scenario for each test case.
            Usage:
            func testMyScenario() async throws {
                scenario = Scenario("description")
                    .given // ...
            }
            """)
        }
        
        try await TestConfiguration.setUpInstance()
        try await TestConfiguration.shared().run(self, currentScenario!)
    }
}
