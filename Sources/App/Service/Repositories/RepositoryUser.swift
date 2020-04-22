//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//

import Vapor
import Fluent

protocol RepositoryUser: Repository {
    func create(_ user: User) -> EventLoopFuture<Void>
    func delete(id: UUID) -> EventLoopFuture<Void>
    func all() -> EventLoopFuture<[User]>
    func find(id: UUID?) -> EventLoopFuture<User?>
    func find(email: String) -> EventLoopFuture<User?>
    func count() -> EventLoopFuture<Int>
}

struct DatabaseRepositoryUser: RepositoryUser, DatabaseRepository {
    let database: Database

    func create(_ user: User) -> EventLoopFuture<Void> {
        return user.create(on: database)
    }

    func delete(id: UUID) -> EventLoopFuture<Void> {
        return User.query(on: database)
            .filter(\.$id == id)
            .delete()
    }

    func all() -> EventLoopFuture<[User]> {
        return User.query(on: database).all()
    }

    func find(id: UUID?) -> EventLoopFuture<User?> {
        return User.find(id, on: database)
    }

    func find(email: String) -> EventLoopFuture<User?> {
        return User.query(on: database)
            .filter(\.$email == email)
            .first()
    }

    func count() -> EventLoopFuture<Int> {
        return User.query(on: database).count()
    }
}

extension Application.Repositories {
    var users: RepositoryUser {
        guard let storage = storage.makeUserRepository else {
            fatalError("UserRepository not configured, use: app.userRepository.use()")
        }

        return storage(app)
    }

    func use(_ make: @escaping (Application) -> (RepositoryUser)) {
        storage.makeUserRepository = make
    }
}

