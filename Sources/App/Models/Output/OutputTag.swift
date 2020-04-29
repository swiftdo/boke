//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/28.
//

import Foundation

struct OutputTag : Output {

    let id: UUID?
    let name: String

    init(tag: Tag) {
        self.id = tag.id
        self.name = tag.name
    }
}
