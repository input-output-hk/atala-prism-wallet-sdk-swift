import Foundation

/// Initializes CucumberLite configuration
class Config: TestConfiguration {
    static var mediatorOobUrl: String = ""
    static var agentUrl: String = ""
    static var publishedDid: String = ""
    static var jwtSchemaGuid: String = ""
    static var anoncredDefinitionGuid: String = ""
    static var apiKey: String = ""
    
    lazy var api: OpenEnterpriseAPI = {
        return api
    }()
    
    override class func createInstance() -> ITestConfiguration {
        return Config()
    }
    
    override func targetDirectory() -> URL {
        return URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Target")
    }
    
    override func createReporters() async throws -> [Reporter] {
        return [ConsoleReporter(), JunitReporter(), HtmlReporter()]
    }
    
    override func createActors() async throws -> [Actor]  {
        let cloudAgent = Actor("Cloud Agent").whoCanUse(OpenEnterpriseAPI())
        let edgeAgent = Actor("Edge Agent").whoCanUse(UseWalletSdk())
        let verifierEdgeAgent = Actor("Verifier Edge Agent").whoCanUse(UseWalletSdk())
        return [cloudAgent, edgeAgent, verifierEdgeAgent]
    }

    override func setUp() async throws {
        Config.mediatorOobUrl = environment["MEDIATOR_OOB_URL"]!
        Config.agentUrl = environment["PRISM_AGENT_URL"]!
        Config.publishedDid = environment["PUBLISHED_DID"] ?? ""
        Config.jwtSchemaGuid = environment["JWT_SCHEMA_GUID"] ?? ""
        Config.anoncredDefinitionGuid = environment["ANONCRED_DEFINITION_GUID"] ?? ""
        Config.apiKey = environment["APIKEY"] ?? ""
        
        // should be initialized after the configuration variables
        let openEnterpriseApi = OpenEnterpriseAPI()
        openEnterpriseApi.createClient()
        self.api = openEnterpriseApi
        
        try await checkPublishedDid()
        try await checkJwtSchema()
        try await checkAnoncredDefinition()
        
        print("Mediator", Config.mediatorOobUrl)
        print("Agent", Config.agentUrl)
        print("DID", Config.publishedDid)
        print("JWT Schema", Config.jwtSchemaGuid)
        print("Anoncred Definition", Config.anoncredDefinitionGuid)
        // TODO: Get SDK version
    }
    
    override func tearDown() async throws {
    }
    
    private func checkPublishedDid() async throws {
        let isPresent = try await api.isDidPresent(Config.publishedDid)
        if (isPresent) {
            return
        }
        print("DID [\(Config.publishedDid)] not found. Creating a new one.")
        
        let unpublishedDid = try await api.createUnpublishedDid()
        let publishedDid = try await api.publishDid(unpublishedDid.longFormDid)
        let shortFormDid = publishedDid.scheduledOperation.didRef
        
        try await Wait.until(timeout: 60) {
            let did = try await api.getDid(shortFormDid)
            return did.status == "PUBLISHED"
        }
        
        Config.publishedDid = shortFormDid
    }
    
    private func checkJwtSchema() async throws {
        let isPresent = try await api.isJwtSchemaGuidPresent(Config.jwtSchemaGuid)
        if (isPresent) {
            return
        }
        print("JWT schema [\(Config.jwtSchemaGuid)] not found. Creating a new one.")
        
        let jwtSchema = try await api.createJwtSchema(author: Config.publishedDid)
        Config.jwtSchemaGuid = jwtSchema.guid
    }
    
    private func checkAnoncredDefinition() async throws {
        let isPresent = try await api.isAnoncredDefinitionPresent(Config.anoncredDefinitionGuid)
        if (isPresent) {
            return
        }
        print("Anoncred Definition not found for [\(Config.anoncredDefinitionGuid)]. Creating a new one.")
        
        let anoncredSchema = try await api.createAnoncredSchema(Config.publishedDid)
        let anoncredDefinition = try await api.createAnoncredDefinition(Config.publishedDid, anoncredSchema.guid)
        Config.anoncredDefinitionGuid = anoncredDefinition.guid
    }
    
    private func writeToGithubSummary(_ command: String) {
        //        if (ProcessInfo.processInfo.environment.keys.contains("CI")) {
        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", command]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            print("Command output:\n\(output)")
        }
    }
}

enum ConfigError: Error {
    case PublishedDIDNotFound
}
