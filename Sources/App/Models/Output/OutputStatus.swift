//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/18.
//

import Foundation

protocol OutputCodeMsg {
    var code: Int { get }
    var message: String { get }
}

struct OutputStatus: Output, OutputCodeMsg {
    var code: Int
    var message: String

    init(code: Int, message: String) {
        self.code = code
        self.message = message
    }
}

extension OutputStatus {
    static var ok = OutputStatus(code: 0, message: "请求成功")
    static var userExist = OutputStatus(code: 20, message: "用户已经存在")
    static var userNotExist = OutputStatus(code: 21, message: "用户不存在")
    static var passwordError = OutputStatus(code: 22, message: "密码错误")
    static var emailNotExist = OutputStatus(code: 23, message: "邮箱不存在")
    static var accessTokenNotExist = OutputStatus(code: 24, message: "access_token不存在")
    static var refreshTokenNotExist = OutputStatus(code: 25, message: "refresh_token不存在")
    static var invalidEmailOrPassword = OutputStatus(code: 26, message: "邮箱或密码错误")
}
