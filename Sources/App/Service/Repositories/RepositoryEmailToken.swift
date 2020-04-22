//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//

import Vapor
import Fluent

protocol RepositoryEmailToken: Repository {
    func find(token: String) -> EventLoopFuture<EmailToken?>
    func create(_ emailToken: EmailToken) -> EventLoopFuture<Void>
    func delete(_ emailToken: EmailToken) -> EventLoopFuture<Void>
    func find(userID: UUID) -> EventLoopFuture<EmailToken?>
}

struct DatabaseRepositoryEmailToken: RepositoryEmailToken, DatabaseRepository {
    let database: Database

    func find(token: String) -> EventLoopFuture<EmailToken?> {
        return EmailToken.query(on: database)
            .filter(\.$token == token)
            .first()
    }

    func create(_ emailToken: EmailToken) -> EventLoopFuture<Void> {
        return emailToken.create(on: database)
    }

    func delete(_ emailToken: EmailToken) -> EventLoopFuture<Void> {
        return emailToken.delete(on: database)
    }

    func find(userID: UUID) -> EventLoopFuture<EmailToken?> {
        EmailToken.query(on: database)
            .filter(\.$user.$id == userID)
            .first()
    }
}


extension Application.Repositories {
    var emailTokens: RepositoryEmailToken {
        guard let factory = storage.makeEmailTokenRepository else {
            fatalError("EmailToken repository not configured, use: app.repositories.use")
        }
        return factory(app)
    }

    func use(_ make: @escaping (Application) -> (RepositoryEmailToken)) {
        storage.makeEmailTokenRepository = make
    }
}





