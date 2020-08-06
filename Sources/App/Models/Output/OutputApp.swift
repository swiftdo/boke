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
        //
        // TODO: 暂时写死



//        self.tops = [
//            Top(type: 1, cover: "http://blog.loveli.site/2020-08-01-git.png", targetId: "44a9d0ca-5c21-4c67-b873-b7f65e8a2e8d", title: "测试"),
//            Top(type: 2, cover: "http://blog.loveli.site/2020-08-01-flutter.png", targetId: "c16fca68-62a6-4b7e-ad7e-1aa18e87643f", title: "测试")
//        ]
//        self.tools = [
//            Tool(type: 1, icon: "http://blog.loveli.site/2020-08-01-%E4%BA%A7%E5%93%81%E6%89%8B%E5%86%8C.png", title: "手册"),
//            Tool(type: 2, icon: "http://blog.loveli.site/2020-08-03-%E7%BE%A4%E8%9C%82%E4%BC%91%E9%97%B2%E5%A8%B1%E4%B9%90---%E5%86%B2.png", title: "休闲"),
//            Tool(type: 3, icon: "http://blog.loveli.site/2020-08-04-%E8%BD%A6%E9%92%A5%E5%8C%99.png", title: "答案")
//        ]
//        self.booklets = booklets

        /// release

        self.tops = [
            Top(type: 1, cover: "http://blog.loveli.site/2020-08-01-git.png", targetId: "cbe1d088-1339-4963-889b-3681efb3db9a", title: "Git 分支策略"),
            Top(type: 2, cover: "http://blog.loveli.site/2020-08-06-doc.png", targetId: "91899df8-22e6-4f81-bc2e-33853a21ff58", title: "中文文档规范")
        ]
        self.tools = [
            Tool(type: 1, icon: "http://blog.loveli.site/2020-08-01-%E4%BA%A7%E5%93%81%E6%89%8B%E5%86%8C.png", title: "手册"),
            Tool(type: 2, icon: "http://blog.loveli.site/2020-08-03-%E7%BE%A4%E8%9C%82%E4%BC%91%E9%97%B2%E5%A8%B1%E4%B9%90---%E5%86%B2.png", title: "休闲"),
            Tool(type: 3, icon: "http://blog.loveli.site/2020-08-04-%E8%BD%A6%E9%92%A5%E5%8C%99.png", title: "答案")
        ]
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
        let type: Int      // 工具类型： 1手册  2 休闲
        let icon: String   // 图标
        let title: String  // 名字
    }
}
