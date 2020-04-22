//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/17.
//

import Vapor
import Fluent

extension Request {
    var authService: AuthenticationService {
        return .init(userReposiotry: self.repositoryUsers,
                     accessTokenRepository: self.repositoryAccessTokens,
                     refreshTokenRepository: self.repositoryRefreshTokens,
                     eventLoop: self.eventLoop,
                     random: self.random)
    }
}

struct AuthenticationService {

    let userReposiotry: RepositoryUser
    let accessTokenRepository: RepositoryAccessToken
    let refreshTokenRepository: RepositoryRefreshToken
    let eventLoop: EventLoop
    let random: RandomGenerator

    //MARK: Actions
    func authentication(refreshToken: String) -> EventLoopFuture<OutputAuthentication> {
        return existingUser(matchingTokenString: refreshToken)
            .unwrap(or: ApiError(code: .userNotExist))
            .flatMap { user in
                do {
                    return try self.authenticationFor(userId: user.requireID())
                } catch {
                    return self.eventLoop.makeFailedFuture(error)
                }
        }
    }

    func authenticationFor(userId: UUID) -> EventLoopFuture<OutputAuthentication> {
        return removeAllTokensFor(userId: userId)
            .flatMap { _ in
                return self.accessTokenFor(userId: userId)
                    .and(self.refreshTokenFor(userId: userId))
                    .map { (accessToken, refreshToken) in
                    return OutputAuthentication(accessToken: accessToken, refreshToken: refreshToken)
                }
        }
    }

    func revokeTokens(forEmail email: String) -> EventLoopFuture<Void> {
        return self.userReposiotry
            .find(email: email)
            .unwrap(or: ApiError(code: .userNotExist))
            .flatMap { user in
                do {
                    return try self.removeAllTokensFor(userId: user.requireID())
                }catch {
                    return self.eventLoop.makeFailedFuture(error)
                }
        }
    }
}

//MARK: Helper
private extension AuthenticationService {

    //MARK: Queries
    func existingUser(matchingTokenString tokenString: RefreshToken.Token) -> EventLoopFuture<User?> {
        return self.refreshTokenRepository
            .find(token: tokenString)
            .unwrap(or: ApiError(code: .refreshTokenNotExist))
            .flatMap {token in
                return self.userReposiotry.find(id: token.$user.id)
            }
    }

    //MARK: Cleanup
    func removeAllTokensFor(userId: UUID) -> EventLoopFuture<Void> {
        return self.accessTokenRepository.delete(for: userId)
            .and(self.refreshTokenRepository.delete(for: userId))
            .map { _, _ in Void() }
    }

    //MARK: Generation
    func accessTokenFor(userId: UUID) -> EventLoopFuture<AccessToken> {
        let token = SHA256.ob.hash(self.random.generate(bits: 256))
        let accessToken = AccessToken(userId: userId, token: token)
        return self.accessTokenRepository
            .create(accessToken)
            .map{ accessToken }
    }

    func refreshTokenFor(userId: UUID) -> EventLoopFuture<RefreshToken> {
        let token = SHA256.ob.hash(self.random.generate(bits: 256))
        let refreshToken = RefreshToken(userId: userId, token: token)
        return self.refreshTokenRepository
            .create(refreshToken)
            .map{ refreshToken }
    }

    func accessTokenFor(refreshToken: RefreshToken) -> EventLoopFuture<AccessToken> {
        return accessTokenFor(userId: refreshToken.$user.id)
    }
}
