//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/19.
//

import Vapor

extension Request {
    // MARK: Repositories
    var repositoryUsers: RepositoryUser { application.repositories.users.for(self) }
    var repositoryRefreshTokens: RepositoryRefreshToken { application.repositories.refreshTokens.for(self) }
    var repositoryEmailTokens: RepositoryEmailToken { application.repositories.emailTokens.for(self) }
    var repositoryAccessTokens: RepositoryAccessToken { application.repositories.accessTokens.for(self) }
    var repositoryUserAuths: RepositoryUserAuth { application.repositories.userAuths.for(self) }
}
