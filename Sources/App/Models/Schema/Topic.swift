//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/22.
//

import Fluent
import Vapor

final class Topic: Content, Model {

    static let schema = "topics"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @OptionalField(key: "cover")
    var cover: String?

    @Parent(key: "subject_id")
    var subject: Subject

    @Parent(key: "author_id")
    var author: User

    @Siblings(through: TopicTag.self, from: \.$topic, to: \.$tag)
    var tags: [Tag]

    @Field(key: "content")
    var content: String // 可能是文章，可能是 html， 可能是视屏

    @OptionalField(key: "remarks")
    var remarks: String? // 文章说明

    @Enum(key: "content_type")
    var contentType: ContentType

    @Field(key: "weight")
    var weight: Int // 帖子权重

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    @OptionalField(key: "url")
    var url: String?

    @OptionalField(key: "source")
    var source: String?

    init() {}

    init(title: String, content: String, subjectID: UUID, authorID: UUID, contentType: ContentType, cover:String? = nil,  weight:Int = 0, url: String? = nil, source: String? = nil) {
        self.title = title
        self.content = content
        self.contentType = contentType
        self.weight = weight
        self.$subject.id = subjectID
        self.$author.id = authorID
        self.cover = cover
        self.url = url
        self.source = source
    }


}


extension Topic {
    enum ContentType: String, Codable {
        static let schema = "CONTENTTYPE"
        case markdown, html
    }
}
