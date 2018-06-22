import FluentMySQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentMySQLProvider())
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)


    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: AppModel.self, database: .mysql)
    services.register(migrations)
    
    /// Register custom MySQL Config
    let mysqlConfig = MySQLDatabaseConfig(hostname: "localhost", port: 3306, username: "root", password: "fox123456", database: "fox")
    services.register(mysqlConfig)
    
    var z = NIOServerConfig.default()
//    z.hostname = "192.168.33.6"
    services.register(z)
}
