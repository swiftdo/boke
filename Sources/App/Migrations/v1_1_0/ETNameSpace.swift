//
//  File.swift
//  
//
//  Created by laijihua on 2020/11/11.
//

import Foundation

struct ETNameSpace {
    enum Permission : CaseIterable {
        case follow
        case collect
        case comment
        case upload
        case moderate
        case administer

        var string: String {
            switch self {
            case .follow: return "FOLLOW"
            case .collect: return "COLLECT"
            case .comment: return "COMMENT"
            case .upload: return "UPLOAD"
            case .moderate: return "MODERATE"
            case .administer: return "ADMINISTER"
            }
        }
        
    
    }

    enum Role : CaseIterable {
        case locked
        case user
        case moderator
        case administrator

        var string: String {
            switch self {
            case .locked:
                return "Locked"
            case .user:
                return "User"
            case .moderator:
                return "Moderator"
            case .administrator:
                return "Administrator"
            }
        }
        
        var permissions: [Permission] {
            switch self {
            case .locked: return [.follow, .collect]
            case .user: return [.follow, .collect, .comment, .upload]
            case .moderator: return [.follow, .collect, .comment, .upload, .moderate]
            case .administrator: return ETNameSpace.Permission.allCases
            }
        }
    }
}
