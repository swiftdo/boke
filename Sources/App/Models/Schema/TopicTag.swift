//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/22.
//

import Fluent
import Vapor

final class TopicTag: Model {

    static let schema = "topic_tags"

    @ID(key: .id) var id: UUID?
    @Parent(key: FieldKeys.tagId) var tag: Tag
    @Parent(key: FieldKeys.topicId) var topic: Topic

    init() {}

    init(tagId: UUID, topicId: UUID) {
        self.$tag.id = tagId
        self.$topic.id = topicId
    }
}

extension TopicTag {
    struct FieldKeys {
        static var tagId: FieldKey { "tag_id" }
        static var topicId: FieldKey { "topic_id" }
    }
}
