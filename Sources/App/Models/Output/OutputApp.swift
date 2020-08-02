//
//  File.swift
//  
//
//  Created by laijihua on 2020/8/1.
//

import Foundation

struct OutputAppLearn : Output {
    let tops: [Top]
    let tools: [Tool]
    let booklets: [OutputBooklet] // 最新手册

    init(booklets: [OutputBooklet]) {
        // TODO: 暂时写死
        self.tops = [
            Top(type: 1, cover: "http://blog.loveli.site/2020-08-01-git.png", targetId: "44a9d0ca-5c21-4c67-b873-b7f65e8a2e8d", title: "测试"),
            Top(type: 2, cover: "http://blog.loveli.site/2020-08-01-flutter.png", targetId: "c16fca68-62a6-4b7e-ad7e-1aa18e87643f", title: "测试")
        ]
        self.tools = [Tool(type: 1, icon: "http://blog.loveli.site/2020-08-01-%E4%BA%A7%E5%93%81%E6%89%8B%E5%86%8C.png", title: "手册")]
        self.booklets = booklets
    }
}

extension OutputAppLearn {
    struct Top: Output {
        let type: Int // 1: blog 2. booklet
        let cover: String  // 封面
        let targetId: String  // 实体 id
        let title: String // 名字
    }

    struct Tool: Output {
        let type: Int      // 工具类型： 1手册
        let icon: String   // 图标
        let title: String  // 名字
    }
}
