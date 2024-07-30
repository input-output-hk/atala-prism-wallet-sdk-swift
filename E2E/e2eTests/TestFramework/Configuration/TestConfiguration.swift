import Foundation
import XCTest
import SwiftHamcrest

class TestConfiguration: ITestConfiguration {
    static var shared = { instance! }
    
    let environment: [String: String] = { readEnvironmentVariables() }()
    private static var instance: ITestConfiguration? = nil
    private static var actors: [String: Actor] = [:]
    
    private var assertionFailure: (String, StaticString, UInt)? = nil
    private var reporters: [Reporter] = []
    
    private var result: ResultOutcome = ResultOutcome()
    private var features: [Feature.Type] = []
    private var steps: [Steps] = []
    
    private var currentFeatureOutcome: FeatureOutcome? = nil
    private var currentScenario: Scenario? = nil
    
    class func createInstance() -> ITestConfiguration {
        fatalError("Configuration must implement createInstance method")
    }
    
    func targetDirectory() -> URL {
        fatalError("Configuration must implement targetDirectory method")
    }
    
    func createActors() async throws -> [Actor]  {
        fatalError("Configuration must implement createActors method")
    }
    
    func setUp() async throws {
        fatalError("Configuration must implement setUp method")
    }
    
    func tearDown() async throws {
        fatalError("Configuration must implement tearDown method")
    }
    
    @MainActor
    static func setUpInstance() async throws {
        if (instance == nil) {
            XCTestObservationCenter.shared.addTestObserver(TestObserver())
        }
        try await setUpConfigurationInstance()
        
    }
    
    /// Refresh for each feature
    func tearDownInstance() async throws {
        try await tearDownSteps()
        try await tearDownActors()
        try await tearDownConfigurationInstance()
    }
    
    func createReporters() async throws -> [Reporter] {
        return [JunitReporter(), HtmlReporter(), DotReporter()]
    }
    
    /// Main function that runs feature, scenario and steps
    func run(_ feature: Feature, _ scenario: Scenario) async throws {
        currentScenario = scenario
        try await beforeFeature(feature)
        try await beforeScenario(scenario)
        let scenarioOutcome = try await runSteps(scenario)
        try await afterScenario(scenarioOutcome)
    }
    
    func beforeFeature(_ feature: Feature) async throws {
        let type: Feature.Type = type(of: feature)
        try await self.setUpActors()
        
        if (features.contains(where: { $0 == type })) {
            return
        }
        
        features.append(type)
        currentFeatureOutcome = FeatureOutcome(feature)
        result.featuresOutcome.append(currentFeatureOutcome!)
        
        try await report(.BEFORE_FEATURE, feature)
    }
    
    func beforeScenario(_ scenario: Scenario) async throws {
        try await report(.BEFORE_SCENARIO, scenario)
    }
    
    func beforeStep(_ step: ConcreteStep) async throws {
        try await report(.BEFORE_STEP, step.action)
    }
    
    func runSteps(_ scenario: Scenario) async throws -> ScenarioOutcome {
        let scenarioOutcome = ScenarioOutcome(scenario)
        
        for step in scenario.steps {
            let stepOutcome: StepOutcome
            try await report(.BEFORE_STEP, step)
            
            do {
                try await StepRegistry.run(step)
                if (assertionFailure != nil) {
                    let message = assertionFailure!.0
                    let file = assertionFailure!.1
                    let line = assertionFailure!.2
                    XCTFail(message, file: file, line: line)
                    throw Assertion.AssertionError(
                        message: message,
                        file: file,
                        line: line
                    )
                }
                stepOutcome = StepOutcome(step)
            } catch {
                stepOutcome = StepOutcome(step, error)
                currentScenario!.fail(file: step.file, line: step.line, message: String(describing: error))
            }
            
            scenarioOutcome.steps.append(stepOutcome)
            try await report(.AFTER_STEP, stepOutcome)
            assertionFailure = nil
            
            if (stepOutcome.error != nil) {
                scenarioOutcome.failedStep = stepOutcome
                break
            }
        }
        return scenarioOutcome
    }
    
    func afterStep(_ stepOutcome: StepOutcome) async throws {
        try await report(.AFTER_STEP, stepOutcome.step.action)
    }
    
    func afterScenario(_ scenarioOutcome: ScenarioOutcome) async throws {
        currentFeatureOutcome!.scenarios.append(scenarioOutcome)
        if (scenarioOutcome.failedStep != nil) {
            currentFeatureOutcome!.failedScenarios.append(scenarioOutcome)
        }
        try await report(.AFTER_SCENARIO, scenarioOutcome)
    }
    
    func afterFeature(_ featureOutcome: FeatureOutcome) async throws {
        try await tearDownActors()
        try await report(.AFTER_FEATURE, featureOutcome)
    }
    
    func afterFeatures(_ featuresOutcome: [FeatureOutcome]) async throws {
        try await report(.AFTER_FEATURES, featuresOutcome)
    }
    
    func endCurrentFeature() async throws {
        try await self.afterFeature(self.currentFeatureOutcome!)
    }
    
    /// signals the suite has ended
    func end() {
        let semaphore = DispatchSemaphore(value: 0)
        Task.init {
            try await self.afterFeatures(self.result.featuresOutcome)
            try await self.tearDownInstance()
            semaphore.signal()
        }
        semaphore.wait()
    }
    
    func report(_ phase: Phase, _ object: Any) async throws {
        for reporter in reporters {
            switch(phase) {
            case .BEFORE_FEATURE:
                try! await reporter.beforeFeature(object as! Feature)
            case .AFTER_FEATURE:
                try! await reporter.afterFeature(object as! FeatureOutcome)
            case .BEFORE_SCENARIO:
                try! await reporter.beforeScenario(object as! Scenario)
            case .AFTER_SCENARIO:
                try! await reporter.afterScenario(object as! ScenarioOutcome)
            case .BEFORE_STEP:
                try! await reporter.beforeStep(object as! ConcreteStep)
            case .AFTER_STEP:
                try! await reporter.afterStep(object as! StepOutcome)
            case .ACTION:
                try! await reporter.action(object as! ActionOutcome)
            case .AFTER_FEATURES:
                try! await reporter.afterFeatures(object as! [FeatureOutcome])
            }
        }
    }
    
    private func setUpActors() async throws {
        let actors = try await createActors()
        for actor in actors {
            TestConfiguration.actors[actor.name] = actor
        }
    }
    
    private func tearDownActors() async throws {
        for actor in TestConfiguration.actors.values {
            try await actor.tearDown()
        }
        TestConfiguration.actors.removeAll()
    }
    
    private func setUpSteps() async throws {
        let subclasses = ClassLocator.subclasses(of: Steps.self)
        for subclass in subclasses {
            if (subclass != Steps.self) {
                steps.append(try await (subclass as! Steps.Type).init())
            }
        }
    }
    
    private func tearDownSteps() async throws {
        for step in steps {
            try await step.tearDown()
        }
    }
    
    private static func setUpConfigurationInstance() async throws {
        if (self.instance != nil) {
            return
        }
        
        let subclasses = ClassLocator.subclasses(of: TestConfiguration.self).filter { $0 != TestConfiguration.self }
        if (subclasses.count == 0) {
            fatalError("No configuration class found. Create a class that extends CucumberConfig class.")
        }
        if (subclasses.count > 1) {
            fatalError("More than 1 configuration class found.")
        }
        
        let instanceType = (subclasses[0] as! ITestConfiguration.Type)
        
        // force as own instance
        let instance = instanceType.createInstance() as! TestConfiguration
        
        try await instance.setUp()
        try await instance.setUpReporters()
        try await instance.setUpSteps()
        
        /// setup hamcrest to update variable if failed
        HamcrestReportFunction = { message, file, line in
            instance.assertionFailure = (message, file, line)
        }
        
        self.instance = instance
        
        let fileManager = FileManager.default
        /// delete target folder
        do {
            try fileManager.removeItem(at: instance.targetDirectory())
        } catch {
        }
        /// recreate it
        do {
            try fileManager.createDirectory(at: instance.targetDirectory(), withIntermediateDirectories: true, attributes: nil)
        } catch {
        }
    }
    
    private func setUpReporters() async throws {
        reporters = try await  createReporters()
    }
    
    private func tearDownConfigurationInstance() async throws {
        try await tearDown()
    }
    
    private static func readEnvironmentVariables() -> [String: String] {
        var environment: [String: String] = [:]
        // load property file
        if let path = Bundle.module.path(forResource: "properties", ofType: "plist", inDirectory: "Resources") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                if let dictionary = try? (PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: String]) {
                    dictionary.forEach {
                        environment[$0.key] = $0.value
                    }
                }
            }
        }
        // overrides if any environment variable is available
        ProcessInfo.processInfo.environment.forEach {
            environment[$0.key] = $0.value
        }
        return environment
    }
    
    /// Default parsers
    @ParameterParser
    var actorParser = { (actor: String) in
        if (!actors.contains(where: { $0.key == actor })) {
            actors[actor] = Actor(actor)
        }
        return actors[actor]!
    }
    
    @ParameterParser
    var stringParser = { (string: String) in
        return string
    }
    
    @ParameterParser
    var intParser = { (int: String) in
        return Int(int)!
    }
    
    enum Failure: Error {
        case StepParameterDoesNotMatch(step: String, expected: String, actual: String)
        case StepNotFound(step: String)
        case ParameterTypeNotFound
    }
}
