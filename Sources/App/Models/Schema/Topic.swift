//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/22.
//

import Fluent
import Vapor

final class Topic: Model {

    static let schema = "topics"

    @ID(key: .id) var id: UUID?
    @Field(key: FieldKeys.title) var title: String
    @OptionalField(key: FieldKeys.cover) var cover: String?
    @Field(key: FieldKeys.content) var content: String // 可能是文章，可能是 html， 可能是视屏
    @OptionalField(key: FieldKeys.remarks) var remarks: String? // 文章说明
    @Field(key: FieldKeys.weight) var weight: Int // 帖子权重
    @OptionalField(key: FieldKeys.url) var url: String? // 文章原始 url
    @OptionalField(key: FieldKeys.source) var source: String? // 来源

    @Parent(key: FieldKeys.subjectId) var subject: Subject
    @Parent(key: FieldKeys.authorId) var author: User
    @Siblings(through: TopicTag.self, from: \.$topic, to: \.$tag) var tags: [Tag]

    @Enum(key: FieldKeys.contentType) var contentType: ContentType

    @Timestamp(key: FieldKeys.createdAt, on: .create) var createdAt: Date?
    @Timestamp(key: FieldKeys.updatedAt, on: .update) var updatedAt: Date?
    @Timestamp(key: FieldKeys.deletedAt, on: .delete) var deletedAt: Date?

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

extension Topic {
    struct FieldKeys {
        static var title: FieldKey { "title" }
        static var cover: FieldKey { "cover" }
        static var subjectId: FieldKey { "subject_id" }
        static var authorId: FieldKey { "author_id" }
        static var content: FieldKey { "content" }
        static var remarks: FieldKey { "remarks" }
        static var contentType: FieldKey { "content_type" }
        static var weight: FieldKey { "weight" }
        static var url: FieldKey { "url" }
        static var userId: FieldKey { "user_id" }
        static var source: FieldKey { "source" }
        static var createdAt: FieldKey { "created_at" }
        static var updatedAt: FieldKey { "updated_at" }
        static var deletedAt: FieldKey { "deleted_at" }
    }
}
