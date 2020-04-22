//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/22.
//

import Fluent
import Vapor

final class Catalog: Content, Model {

    static let schema = "catalogs"

    @ID(key: .id)
    var id: UUID?
}
