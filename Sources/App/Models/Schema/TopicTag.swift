//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/22.
//

import Fluent
import Vapor

final class TopicTag: Model {

    static let schema = "topic_tag"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "tag_id")
    var tag: Tag


    @Parent(key: "topic_id")
    var topic: Topic

    init() {}

    init(tagID: UUID, topicID: UUID) {
        self.$tag.id = tagID
        self.$topic.id = topicID
    }

}
