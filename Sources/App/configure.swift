import Fluent
import FluentPostgresDriver
import QueuesRedisDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    let error = ErrorMiddleware.custom(environment: app.environment)
    app.middleware = .init()
    app.middleware.use(cors)
    app.middleware.use(error)

    /// 初始化数据库
    if let dbURL = Environment.dbURL {
        app.databases.use(try .postgres(url: dbURL), as: .psql)
    } else {
        switch app.environment {
        case .production:
            app.databases.use(.postgres(
                hostname: Environment.dbHost ?? "localhost",
                username: Environment.dbUser ?? "username",
                password: Environment.dbPwd  ?? "password",
                database: Environment.dbName ?? "boke"
            ), as: .psql)
        default:
            // macos
            app.databases.use(.postgres(
                hostname: Environment.dbHost ?? "localhost",
                username: Environment.dbUser ?? "root",
                password: Environment.dbPwd  ?? "",
                database: Environment.dbName ?? "oldbirds"
            ), as: .psql)
        }
    }

    /// queue
    switch app.environment {
    case .production:
        try app.queues.use(.redis(url: "redis://\(Environment.redisHost ?? "127.0.0.1"):6379"))
    default:
        try app.queues.use(.redis(url: "redis://127.0.0.1:6379"))
    }
    let emailJob = EmailJob()
    app.queues.add(emailJob)

    try app.queues.startInProcessJobs(on: .default)

    try routes(app)
    try migrations(app)
    try services(app)
}

extension Environment {
    static let dbHost = Self.get("DATABASE_HOST")
    static let dbUser = Self.get("DATABASE_USERNAME")
    static let dbPwd  = Self.get("DATABASE_PASSWORD")
    static let dbName = Self.get("DATABASE_NAME")
    static let dbURL  = Self.get("DATABASE_URL")
    static let redisHost = Self.get("REDIS_HOST")
}

