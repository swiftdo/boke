import Fluent
import Vapor
import Queues

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    let tokenAuthRoutes = app.grouped(AccessToken.authenticator(), User.guardMiddleware())
    tokenAuthRoutes.get("me") { req  in
        return try OutputJson(success: OutputUser(from:  req.auth.require(User.self)))
    }

    app.get("send-email") { req in
        return req.queue
            .dispatch(
                EmailJob.self,
                EmailContent.init(to: "1164258202@qq.com", message: "hello world", subject: "测试")
            ).map {
                OutputJson(success: "ok")
            }
    }

    try app.group("api") { api in
        try api.register(collection: AuthController())
        try api.register(collection: SubjectController())
        try api.register(collection: TagController())
        try api.register(collection: TopicController())
        try api.register(collection: BookletController())
        try api.register(collection: AppController())
        try api.register(collection: UserController())
    }
}
