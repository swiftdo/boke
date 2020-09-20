//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/22.
//

import Fluent
import Vapor

final class Tag: Model {

    static let schema = "tags"

    @ID(key: .id) var id: UUID?
    @Field(key: FieldKeys.name) var name: String
    @OptionalField(key: FieldKeys.remarks) var remarks: String?
    @Siblings(through: TopicTag.self, from: \.$tag, to: \.$topic) var topics: [Topic]
    @Timestamp(key: FieldKeys.createdAt, on: .create) var createdAt: Date?

    init() { }

    init(name: String, remarks: String?) {
        self.name = name
        self.remarks = remarks
    }
}

extension Tag {
    struct FieldKeys {
        static var name: FieldKey { "name" }
        static var remarks: FieldKey { "remarks" }
        static var createdAt: FieldKey { "created_at" }
    }
}

