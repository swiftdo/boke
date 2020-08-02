import Fluent
import Vapor
import SMTP

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in

        return "Hello, oldbirds! docker"
    }

    let tokenAuthRoutes = app.grouped(AccessToken.authenticator(), User.guardMiddleware())
    tokenAuthRoutes.get("me") { req  in
        return try OutputJson(success: OutputUser(from:  req.auth.require(User.self)))
    }

    app.get("send-email") { req in
        req.smtp
            .send(Email(from: EmailAddress(address: "13576051334@163.com", name: "lai"), to: [EmailAddress(address: "1814345797@qq.com", name: "小号")], subject: "测试", body: "hello world")).map { err in
                return OutputJson(success: "\(String(describing: err))")
        }
    }

    try app.group("api") { api in
        try api.register(collection: AuthController())
        try api.register(collection: SubjectController())
        try api.register(collection: TagController())
        try api.register(collection: TopicController())
        try api.register(collection: BookletController())
        try api.register(collection: AppController())
    }
}
