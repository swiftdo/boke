//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/22.
//

import Fluent
import Vapor

final class Tag: Content, Model {

    static let schema = "tags"

    @ID(key: .id)
    var id: UUID?

    @Siblings(through: TopicTag.self, from: \.$tag, to: \.$topic)
    var topics: [Topic]

}
