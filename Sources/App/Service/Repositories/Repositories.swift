//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//

import Vapor
import Fluent

protocol Repository: RequestService {}

protocol DatabaseRepository: Repository {
    var database: Database { get }
    init(database: Database)
}

extension DatabaseRepository {
    func `for`(_ req: Request) -> Self {
        return Self.init(database: req.db)
    }
}

extension Application {

    struct Repositories {
        struct Provider {
            static var database: Self {
                /// 初始化 Provider
                return .init {
                    $0.repositories.use { DatabaseRepositoryUser(database: $0.db) }
                    $0.repositories.use { DatabaseRepositoryEmailToken(database: $0.db) }
                    $0.repositories.use { DatabaseRepositoryRefreshToken(database: $0.db) }
                    $0.repositories.use { DatabaseRepositoryAccessToken(database: $0.db) }
                    $0.repositories.use { DatabaseRepositoryUserAuth(database: $0.db) }
                }
            }

            let run: (Application) -> ()
        }

        /// 存放闭包
        final class Storage {
            var makeUserRepository: ((Application) -> RepositoryUser)?
            var makeUserAuthRepository: ((Application) -> RepositoryUserAuth)?
            var makeEmailTokenRepository: ((Application) -> RepositoryEmailToken)?
            var makeRefreshTokenRepository: ((Application) -> RepositoryRefreshToken)?
            var makeAccessTokenRepository: ((Application) -> RepositoryAccessToken)?
            init() { }
        }

        struct Key: StorageKey {
            typealias Value = Storage
        }

        let app: Application

        func use(_ provider: Provider) {
            provider.run(app)
        }

        /// 给 Repositories 创建个存储位置
        var storage: Storage {
            if app.storage[Key.self] == nil {
                app.storage[Key.self] = .init()
            }

            return app.storage[Key.self]!
        }
    }

}

extension Application {
    var repositories: Repositories {
        /// 因为是 struct, 所有有默认构造器
        .init(app: self)
    }
}


