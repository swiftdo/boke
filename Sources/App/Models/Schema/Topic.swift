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

    @Siblings(through: TopicTag.self, from: \.$topic, to: \.$tag)
    var tags: [Tag]
}
