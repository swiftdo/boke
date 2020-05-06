//
//  File.swift
//  
//
//  Created by laijihua on 2020/5/6.
//

import Foundation

struct OutputBooklet: Output {

    let id: UUID?
    let name: String
    let cover: String?
    let remarks: String?
    let author: OutputUser
    let catalogId: UUID

    init(booklet: Booklet) {
        self.id = booklet.id
        self.name = booklet.name
        self.cover = booklet.cover
        self.remarks = booklet.remarks
        self.author = OutputUser(from: booklet.author)
        self.catalogId = booklet.catalogId
    }
}
