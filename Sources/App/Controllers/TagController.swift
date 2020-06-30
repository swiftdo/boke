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
            authGroup.post("delete", ":id", use: delete)

            tag.get("all", use: all)
            tag.get(":id", "topics", use: getTopics)
        }
    }
}

extension TagController {
    private func all(_ req: Request) throws -> EventLoopFuture<OutputJson<[OutputTag]>> {
        return req.repositoryTags.all().map { $0.map { OutputTag(tag: $0)}}.map { OutputJson(success: $0)}
    }

    private func getTopics(_ req: Request) throws -> EventLoopFuture<OutputJson<Page<OutputTopic>>> {
        guard let idStr = req.parameters.get("id", as: String.self), let id = UUID(uuidString: idStr) else {
            throw ApiError(code: OutputStatus.missParameters)
        }

        return req.repositoryTags
            .find(id)
            .unwrap(or: ApiError(code: .subjectNotExist))
            .flatMap { tag in
                return tag.$topics
                    .query(on: req.db)
                    .with(\.$subject)
                    .with(\.$author)
                    .with(\.$tags)
                    .paginate(for: req)
                    .map { page in
                        return page.map{ OutputTopic(topic: $0) }
                }
        }.map {
            OutputJson(success: $0)
        }
    }

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

    private func delete(_ req: Request) throws -> EventLoopFuture<OutputJson<String>> {
        guard let idStr = req.parameters.get("id", as: String.self), let id = UUID(uuidString: idStr) else {
            throw ApiError(code: OutputStatus.missParameters)
        }
        return req.repositoryTags.delete(id).transform(to: OutputJson(success: "成功删除"))
    }
}
