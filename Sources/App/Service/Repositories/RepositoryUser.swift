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
    func update(user: User) -> EventLoopFuture<User>
    func count() -> EventLoopFuture<Int>
    func permissions(id: UUID?) -> EventLoopFuture<[Permission]>
    func can(id: UUID?, permission: ETNameSpace.Permission) throws -> EventLoopFuture<Bool>
    func isAdmin(id: UUID?) -> EventLoopFuture<Bool>
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

    func update(user: User) -> EventLoopFuture<User> {
        return user.update(on: database).map { user }
    }
    
    func permissions(id: UUID?) -> EventLoopFuture<[Permission]> {
        return User
            .find(id, on: database)
            .unwrap(or: ApiError(code: .userNotExist))
            .flatMap { user in
                user.$role.get(on: database).unwrap(or: ApiError(code: .roleNotExist))
            }
            .flatMap { (role: Role) in
                role.$permissons.get(on: database)
            }
    }
    
    func can(id: UUID?, permission: ETNameSpace.Permission) throws -> EventLoopFuture<Bool> {
        let permissionId = Permission
            .query(on: database)
            .filter(\.$name == permission.string)
            .first()
            .unwrap(or: ApiError(code: .permissionNotExist))
            .flatMapThrowing { try $0.requireID() }
            
        return User
            .find(id, on: database)
            .unwrap(or: ApiError(code: .userNotExist))
            .flatMap { user in
                user.$role.get(on: database).unwrap(or: ApiError(code: .roleNotExist))
            }
            .and(permissionId)
            .flatMap { (role: Role, perId: UUID) in
                role.$permissons.query(on: database).filter(\.$id == perId).count().map{ $0 > 0 }
            }
    }
    
    func isAdmin(id: UUID?) -> EventLoopFuture<Bool> {
        return User
            .find(id, on: database)
            .unwrap(or: ApiError(code: .userNotExist))
            .flatMap { user in
                user.$role.get(on: database).map { role in
                    if let role = role {
                        return role.name == ETNameSpace.Role.administrator.string
                    } else {
                        return false
                    }
                }
            }
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

