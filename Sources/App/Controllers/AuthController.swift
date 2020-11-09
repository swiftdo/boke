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
            
            auth.group("email", "verification") { emailVerificationRoutes in
                /// 用户没有在注册的时候进行验证，需要提供个操作，点击发送邮箱
                emailVerificationRoutes.post("send", use: sendEmailVerification)
                
                /// 邮箱验证
                emailVerificationRoutes.get(":id", use: verifyEmail)
            }

            auth.group("password") { resetPasswordRoutes in
                resetPasswordRoutes.post("reset", use: resetPassword)
//                resetPasswordRoutes.post("forget", use: forgetPassword)
            }
        }

    }
}

extension AuthController {
    
    private func sendEamilVerifyToken(req: Request, userId: UUID, email: String) -> EventLoopFuture<EventLoopFuture<Void>> {
        let token = SHA256.ob.hash(req.random.generate(bits: 256))
        let emailToken = EmailToken(userID: userId, token: token)
        return req.repositoryEmailTokens
            .create(emailToken)
            .flatMapThrowing { _ in
                let url = try Config.urlPre + "auth/email/verification/\(emailToken.requireID())"
                let content = EmailContent(to: email, message: "点击链接完成认证<a href=\"\(url)\">\(url)</a>", subject: "【BoKe】认证验证")
                return req.queue.dispatch(EmailJob.self, content)
            }
    }
    
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
                return try (UserAuth(userId: user.requireID(), authType: .email, identifier: inputRegister.email, credential: pwd), user.requireID())
            }
            .flatMap { (userAuth, userId) in
                return req.repositoryUserAuths
                    .create(userAuth)
                    .flatMap { (_) -> EventLoopFuture<EventLoopFuture<Void>> in
                        return sendEamilVerifyToken(req: req, userId: userId, email: inputRegister.email)
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



    private func sendEmailVerification(_ req: Request) throws -> EventLoopFuture<OutputJson<OutputCreate>>{
        /// 获取用户 id
        guard let id = req.parameters.get("id", as: String.self), let uuid = UUID(uuidString: id) else {
            throw ApiError(code: OutputStatus.missParameters)
        }
        
        return req.repositoryUsers
            .find(id: uuid)
            .unwrap(or: ApiError(code: OutputStatus.userNotExist))
            .flatMap { (user) -> EventLoopFuture<EventLoopFuture<Void>> in
                return sendEamilVerifyToken(req: req, userId: uuid, email: user.email)
            }
            .map { _ in OutputJson(success: OutputCreate())}
    }
    
    private func verifyEmail(_ req: Request) throws -> EventLoopFuture<OutputJson<String>> {
        guard let id = req.parameters.get("id", as: String.self), let uuid = UUID(uuidString: id) else {
            throw ApiError(code: OutputStatus.missParameters)
        }
        return EmailToken.find(uuid, on: req.db)
            .unwrap(or: ApiError(code: .emailTokenNotExist))
            .flatMap { token in
            let result: OutputJson<String> = token.expiresAt > Date() ? OutputJson(success: "认证成功") :  OutputJson(error: .emailTokenFail)
            return token.delete(on: req.db).map { _ in result}
        }
    }
    
    /// 重置密码
    private func resetPassword(_ req: Request) throws -> EventLoopFuture<OutputJson<String>>{
        /// 重置密码，用户id, 新密码，旧密码
        let inputResetPwd = try req.content.decode(InputResetPwd.self)
        guard let uuid = UUID(inputResetPwd.id) else {
            throw ApiError(code: OutputStatus.missParameters)
        }
        
        return req.repositoryUserAuths
            .find(authType: .email, userId: uuid)
            .unwrap(or: ApiError(code: .userAuthNotExist))
            .map { userAuth in
                return req.password
                    .async
                    .verify(inputResetPwd.opwd, created: userAuth.credential)
                    .guard({$0 == true}, else: ApiError(code: .invalidEmailOrPassword))
                    .map { _ in
                        userAuth.credential = inputResetPwd.pwd
                        _ = userAuth.save(on: req.db)
                    }
            }.map { _ in return OutputJson(success: "更换成功")}
    }
    
    /// 忘记密码
//    private func forgetPassword(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
//        // 邮箱，新密码，再次输入密码，验证码
//
//
//        
//    }
}
