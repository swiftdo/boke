//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//

import Vapor
import Fluent

protocol RepositoryUserAuth: Repository {
    func find(authType:UserAuth.AuthType, identifier: String) -> EventLoopFuture<UserAuth?>
    func create(_ auth: UserAuth) -> EventLoopFuture<Void>
}

struct DatabaseRepositoryUserAuth: RepositoryUserAuth, DatabaseRepository {
    let database: Database

    func find(authType: UserAuth.AuthType, identifier: String) -> EventLoopFuture<UserAuth?> {
        return UserAuth.query(on: database)
            .filter(\.$authType == authType)
            .filter(\.$identifier == identifier)
            .first()
    }

    func create(_ auth: UserAuth) -> EventLoopFuture<Void> {
        return auth.create(on: database)
    }
}

extension Application.Repositories {
    var userAuths: RepositoryUserAuth {
        guard let storage = storage.makeUserAuthRepository else {
            fatalError("UserRepository not configured, use: app.userRepository.use()")
        }

        return storage(app)
    }

    func use(_ make: @escaping (Application) -> (RepositoryUserAuth)) {
        storage.makeUserAuthRepository = make
    }
}
