//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/29.
//

import Fluent
import Vapor

struct TagController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.group("tag") { tag in
            let authGroup = tag.grouped(AccessToken.authenticator(), User.guardMiddleware())
            authGroup.post("add", use: add)
        }
    }
}

extension TagController {
    private func add(_ req: Request) throws -> EventLoopFuture<OutputJson<OutputTag>> {
        let inputTag = try req.content.decode(InputTag.self)
        return req.repositoryTags
            .find(name: inputTag.name)
            .guard({ $0 == nil }, else: ApiError(code: .subjectExist))
            .transform(to: Tag(name: inputTag.name, remarks: inputTag.remarks))
            .flatMap { tag in
                return req.repositoryTags.create(tag).map { _ in OutputJson(success: OutputTag(tag: tag))}
            }
    }
}
