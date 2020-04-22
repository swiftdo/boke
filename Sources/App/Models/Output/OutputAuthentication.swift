//
//  File.swift
//  
//
//  Created by laijihua on 2020/4/18.
//
import Foundation

struct OutputAuthentication: Output {
    //MARK: Properties
    let accessToken: AccessToken.Token
    let expiresAt: TimeInterval
    let refreshToken: RefreshToken.Token

    // MARK: Initializers
    init(accessToken: AccessToken, refreshToken: RefreshToken) {
        self.accessToken = accessToken.token
        self.expiresAt = accessToken.expiresAt.timeIntervalSince1970
        self.refreshToken = refreshToken.token
    }
}
