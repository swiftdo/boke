//
//  File.swift
//  
//
//  Created by laijihua on 2020/5/6.
//

import Fluent
import Vapor

/// 小册
final class Booklet: Content, Model {

    static let schema = "booklets"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @OptionalField(key: "cover")
    var cover: String?

    @OptionalField(key: "remarks")
    var remarks: String?

    @Parent(key: "author_id")
    var author: User

    @Field(key: "catalog_id")
    var catalogId: UUID

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    init() {

    }

    init(id: UUID? = nil, name: String, userId: UUID, catalogId: UUID, cover: String? = nil, remarks: String? = nil ) {
        self.id = id
        self.name = name
        self.cover = cover
        self.remarks = remarks
        self.$author.id = userId
        self.catalogId = catalogId
    }

}
