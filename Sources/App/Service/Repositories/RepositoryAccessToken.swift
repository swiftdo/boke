//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//
import Vapor
import Fluent

protocol RepositoryAccessToken: Repository {
    func find(userID: UUID) -> EventLoopFuture<AccessToken?>
    func find(token: String) -> EventLoopFuture<AccessToken?>
    func count() -> EventLoopFuture<Int>
    func create(_ accessToken: AccessToken) -> EventLoopFuture<Void>
    func delete(_ accessToken: AccessToken) -> EventLoopFuture<Void>
    func delete(for userID: UUID) -> EventLoopFuture<Void>
}

struct DatabaseRepositoryAccessToken: RepositoryAccessToken, DatabaseRepository {

    var database: Database

    func find(userID: UUID) -> EventLoopFuture<AccessToken?> {
        AccessToken.query(on: database)
            .filter(\.$user.$id == userID)
            .first()
     }

    func find(token: String) -> EventLoopFuture<AccessToken?> {
        AccessToken.query(on: database)
            .filter(\.$token == token)
            .first()
    }

    func count() -> EventLoopFuture<Int> {
        AccessToken.query(on: database).count()
    }

    func create(_ accessToken: AccessToken) -> EventLoopFuture<Void> {
        accessToken.create(on: database)
    }

    func delete(_ accessToken: AccessToken) -> EventLoopFuture<Void> {
        accessToken.delete(on: database)
    }

    func delete(for userID: UUID) -> EventLoopFuture<Void> {
        AccessToken.query(on: database)
            .filter(\.$user.$id == userID)
            .delete()
    }
}

extension Application.Repositories {
    var accessTokens: RepositoryAccessToken {
        guard let factory = storage.makeAccessTokenRepository else {
            fatalError("AccessToken repository not configured, use: app.repositories.use")
        }
        return factory(app)
    }

    func use(_ make: @escaping (Application) -> (RepositoryAccessToken)) {
        storage.makeAccessTokenRepository = make
    }
}
