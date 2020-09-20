//
//  File.swift
//  
//
//  Created by laijihua on 2020/5/6.
//

import Fluent
import Vapor

import Fluent
import Vapor

/// 小册
final class Booklet: Model {

    static let schema = "booklets"

    @ID(key: .id) var id: UUID?
    @Field(key: FieldKeys.name) var name: String
    @OptionalField(key: FieldKeys.cover) var cover: String?
    @OptionalField(key: FieldKeys.remarks) var remarks: String?
    @Parent(key: FieldKeys.authorId) var author: User
    @Field(key: FieldKeys.catalogId) var catalogId: UUID
    @Timestamp(key: FieldKeys.createdAt, on: .create) var createdAt: Date?
    @Timestamp(key: FieldKeys.updatedAt, on: .update) var updatedAt: Date?
    @Timestamp(key: FieldKeys.deletedAt, on: .delete) var deletedAt: Date?

    init() {

    }

    init(id: UUID? = nil, name: String, userId: UUID, catalogId: UUID, cover: String? = nil, remarks: String? = nil) {
        self.id = id
        self.name = name
        self.cover = cover
        self.remarks = remarks
        self.$author.id = userId
        self.catalogId = catalogId
    }

}

extension Booklet {
    struct FieldKeys {
        static var name: FieldKey { "name" }
        static var cover: FieldKey { "cover" }
        static var remarks: FieldKey { "remarks" }
        static var authorId: FieldKey { "author_id" }
        static var catalogId: FieldKey { "catalog_id" }
        static var createdAt: FieldKey { "created_at" }
        static var updatedAt: FieldKey { "updated_at" }
        static var deletedAt: FieldKey { "deleted_at" }
    }
}
