//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/22.
//

import Fluent

struct CreateTopicTag: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(TopicTag.schema)
            .id()
            .field(TopicTag.FieldKeys.tagId, .uuid, .required, .references(Tag.schema, .id))
            .field(TopicTag.FieldKeys.topicId, .uuid, .required, .references(Topic.schema, .id))
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(TopicTag.schema).delete()
    }
}
