//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/29.
//


import Fluent
import Vapor

struct TopicController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.group("topic") { topic in
            let authGroup = topic.grouped(AccessToken.authenticator(), User.guardMiddleware())
            authGroup.post("add", use: add)
            authGroup.post("delete", ":id", use: delete)
            topic.get(":id", use: detail)
            topic.get("all", use: all)

        }
    }
}

extension TopicController {
    private func detail(_ req: Request) throws -> EventLoopFuture<OutputJson<OutputTopic>> {
        guard let idStr = req.parameters.get("id", as: String.self), let id = UUID(uuidString: idStr) else {
            throw ApiError(code: OutputStatus.missParameters)
        }
        return req.repositoryTopics
            .find(id)
            .unwrap(or: ApiError(code: OutputStatus.topicNotExist))
            .map{ OutputJson(success: OutputTopic(topic: $0))}
    }

    private func all(_ req: Request) throws -> EventLoopFuture<OutputJson<Page<OutputTopic>>> {
        return req.repositorySubjects
            .find(name: "booklet")
            .unwrap(or: ApiError.init(code: .subjectNotExist))
            .flatMapThrowing{ subject in
                try subject.requireID()
            }
            .flatMap { subjectId in
                return Topic
                .query(on: req.db)
                    .filter(\.$subject.$id != subjectId) // booklet
                .sort(\.$createdAt, .descending)
                .with(\.$subject)
                .with(\.$author)
                .with(\.$tags)
                .paginate(for: req)
                .map { page in
                    return page.map{ OutputTopic(topic: $0) }
                }.map {
                    return OutputJson(success: $0)
                }
            }
    }

    private func delete(_ req: Request) throws -> EventLoopFuture<OutputJson<String>> {
        guard let idStr = req.parameters.get("id", as: String.self), let id = UUID(uuidString: idStr) else {
            throw ApiError(code: OutputStatus.missParameters)
        }
        return req.repositoryTopics.delete(id).transform(to: OutputJson(success: "成功删除"))
    }


    private func add(_ req: Request) throws -> EventLoopFuture<OutputJson<OutputTopic>> {
        let user = try req.auth.require(User.self)
        let inputTopic = try req.content.decode(InputTopic.self)

        let subjectFuture = req.repositorySubjects
            .find(id: UUID(uuidString: inputTopic.subjectId))
            .unwrap(or: ApiError(code: .subjectNotExist))

        let tagFutures = inputTopic.tagIds
            .split(separator: ",")
            .map { UUID(uuidString: String($0))}
            .compactMap { uuid in
            return req.repositoryTags.find(uuid).unwrap(or: ApiError(code: .tagNotExist))
        }.flatten(on: req.eventLoop)

        return subjectFuture.flatMapThrowing { subject in
            return try Topic(title: inputTopic.title,
                                  content: inputTopic.content,
                                  subjectID: subject.requireID(),
                                  authorID: user.requireID(),
                                  contentType: inputTopic.contentType,
                                  cover: inputTopic.cover,
                                  weight: inputTopic.weight,
                                  url: inputTopic.url,
                                  source: inputTopic.source)

        }.flatMap { topic in
            return req.repositoryTopics.create(topic).map { topic }
        }
        .and(tagFutures)
        .flatMap{ (topic, tags) in
            return tags.map { tag in
                return topic.$tags.attach(tag, on: req.db)
            }
            .flatten(on: req.eventLoop)
            .transform(to: topic)
        }.flatMapThrowing{ topic in
            try topic.requireID()
        }
        .flatMap { topicId in
            return req
                .repositoryTopics
                .find(topicId)
                .unwrap(or: ApiError(code: .topicNotExist))
                .map{ OutputJson(success: OutputTopic(topic: $0))}
        }
    }
}
