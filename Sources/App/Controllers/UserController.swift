//
//  File.swift
//  
//
//  Created by laijihua on 2020/9/23.
//


import Fluent
import Vapor

struct UserController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        routes.group("user") { auth in
            let authGroup = auth.grouped(AccessToken.authenticator(), User.guardMiddleware())
            authGroup.post("update", use: updateUser)

        }
    }
}

extension UserController {
    /// 用户资料更新
    private func updateUser(_ req: Request) throws -> EventLoopFuture<OutputJson<OutputUser>> {
        guard let user = req.auth.get(User.self) else {
            throw ApiError(code: OutputStatus.userNotExist)
        }
        let inputUser = try req.content.decode(InputUser.self)
        if let avatar = inputUser.avatar {
            user.avatar = avatar
        }
        if let name = inputUser.name {
            user.name = name
        }
        return req.repositoryUsers.update(user: user).map {user in
            OutputJson(success: OutputUser(from: user))
        }
    }
}
