//
//  File.swift
//  
//
//  Created by laijihua on 2020/5/6.
//

import Vapor
import Fluent

protocol RepositoryBooklet: Repository {

}

struct DatabaseRepositoryBooklet: RepositoryBooklet, DatabaseRepository {
    let database: Database


}


extension Application.Repositories {
    var booklets: RepositoryBooklet {
        guard let factory = storage.makeBookletRepository else {
            fatalError("EmailToken repository not configured, use: app.repositories.use")
        }
        return factory(app)
    }

    func use(_ make: @escaping (Application) -> (RepositoryBooklet)) {
        storage.makeBookletRepository = make
    }
}
