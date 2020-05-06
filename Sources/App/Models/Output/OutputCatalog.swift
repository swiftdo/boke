//
//  File.swift
//  
//
//  Created by laijihua on 2020/5/6.
//

import Foundation


struct OutputCatalog: Output {

    let id: UUID?
    let pid: UUID?
    let title: String
    let path: String?
    let level: Int
    let order: Int
    let topicId: UUID?
    var child: [OutputCatalog]

    init(catalog: Catalog, child: [OutputCatalog] = []) {
        self.id = catalog.id
        self.pid = catalog.parentCatalog?.id
        self.title = catalog.title
        self.path = catalog.path
        self.level = catalog.level
        self.order = catalog.order
        self.child = child
        self.topicId = catalog.topicId
    }
}
