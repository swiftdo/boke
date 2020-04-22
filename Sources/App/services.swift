//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//

import Vapor
import SMTP

func services(_ app: Application) throws {

    app.randomGenerators.use(.random)
    /// 初始化 Repositorys
    app.repositories.use(.database)

    app.smtp.use(SMTPServerConfig(hostname: "smtp.163.com",
                                  port: 465,
                                  username: "13576051334@163.com",
                                  password: "ZNZEIMJTGRWQSHOB", // ZNZEIMJTGRWQSHOB， 第三方生成秘钥
                                  tlsConfiguration: .regularTLS))
}
