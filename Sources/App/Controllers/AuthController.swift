//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/17.
//

import Fluent
import Vapor
import SMTP

struct AuthController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        routes.group("auth") { auth in
            /// 注册
            auth.post("register", use: register)
            /// 登录
            auth.post("login", use: login)
            /// 更新 accesstoken
            auth.post("accessToken", use: refreshAccessToken)
            
//            auth.group("email", "verification") { emailVerificationRoutes in
//                emailVerificationRoutes.post("", use: sendEmailVerification)
//                emailVerificationRoutes.get("", use: verifyEmail)
//            }
//
//            auth.group("reset", "password") { resetPasswordRoutes in
//                resetPasswordRoutes.post("", use: resetPassword)
//                resetPasswordRoutes.get("verify", use: verifyResetPasswordToken)
//            }
//            auth.post("recover", use: recoverAccount)


        }

    }
}

extension AuthController {
    private func register(_ req: Request) throws -> EventLoopFuture<OutputJson<OutputCreate>> {
        try InputRegister.validate(content: req)
        let inputRegister = try req.content.decode(InputRegister.self)

        return req.repositoryUserAuths
            .find(authType: .email, identifier: inputRegister.email)
            .guard({ $0 == nil }, else: ApiError(code: .userExist))
            .transform(to: User(name: inputRegister.name, email: inputRegister.email))
            .flatMap { user in
                return req.repositoryUsers.create(user).map { user }
            }
            .and(req.password.async.hash(inputRegister.password))
            .flatMapThrowing { user, pwd in
                return try UserAuth(userId: user.requireID(), authType: .email, identifier: inputRegister.email, credential: pwd)
            }
            .flatMap { userAuth in
                return userAuth
                    .create(on: req.db)
                    .map { _ in
                        // 发送认证邮件
                        let email = Email(from: EmailAddress(address: "13576051334@163.com"), to: [EmailAddress(address: inputRegister.email)], subject: "【Boke】注册认证", body: "欢迎你的使用")
                        _ = req.smtp.send(email)
                    }
                    .map { _ in OutputJson(success: OutputCreate())}
            }
    }

    private func login(_ req: Request) throws -> EventLoopFuture<OutputJson<OutputLogin>> {
        try InputLogin.validate(content: req)
        let inputLogin = try req.content.decode(InputLogin.self)
        return req.repositoryUserAuths
            .find(authType: .email, identifier: inputLogin.email)
            .unwrap(or: ApiError(code: .emailNotExist))
            .flatMap { userAuth in
                return req.password
                    .async
                    .verify(inputLogin.password, created: userAuth.credential)
                    .guard({$0 == true}, else: ApiError(code: .invalidEmailOrPassword))
                    .transform(to: userAuth)
        }.flatMap { userAuth in
            return userAuth.$user.get(on: req.db)
        }.flatMap { user in
            do {
                req.auth.login(user)
                let tokenFuture = req.authService.authenticationFor(userId: try user.requireID())
                return tokenFuture
                    .map({ token in
                        OutputJson(success: OutputLogin(user: OutputUser(from: user), token: token))
                    })
            } catch {
                return req.eventLoop.makeFailedFuture(error)
            }
        }
    }

    private func refreshAccessToken(_ req: Request) throws -> EventLoopFuture<OutputJson<OutputAuthentication>> {
        let inputAccessToken = try req.content.decode(InputAccessToken.self)
        return req.authService
            .authentication(refreshToken: inputAccessToken.refreshToken)
            .map{ OutputJson(success: $0) }
    }



//    private func sendEmailVerification(_ req: Request) throws -> EventLoopFuture<HTTPStatus>{}
//    private func recoverAccount(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {}
//    private func verifyEmail(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {}
//    private func resetPassword(_ req: Request) throws -> EventLoopFuture<HTTPStatus>{}
//    private func verifyResetPasswordToken(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {}
}
