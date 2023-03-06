//
//  Font+.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/18.
//

import Foundation
import SwiftUI

extension Font {
    
    enum BMJUA {
        case regular
        case custom(String)
        
        var value: String {
            switch self {
            case .regular:
                return "BMJUAOTF"
            case .custom(let name):
                return name
            }
        }
    }
    
    enum CookieRun {
        case regular
        case bold
        case black
        case custom(String)
        
        var value: String {
            switch self {
            case .regular:
                return "CookieRunOTF-Regular"
            case .bold:
                return "CookieRunOTF-Bold"
            case .black:
                return "CookieRunOTF-Black"
            case .custom(let name):
                return name
            }
        }
    }
    
    enum GmarketSans {
        case light
        case medium
        case bold
        case custom(String)
        
        var value: String {
            switch self {
            case .light:
                return "GmarketSansLight"
            case .medium:
                return "GmarketSansMedium"
            case .bold:
                return "GmarketSansBold"
            case .custom(let name):
                return name
            }
        }
    }
    
    static func bmjua(_ type: BMJUA, size: CGFloat = 17) -> Font {
        return .custom(type.value, size: size)
    }
    
    static func cookieRun(_ type: CookieRun, size: CGFloat = 17) -> Font {
        return .custom(type.value, size: size)
    }
    
    static func gmarketSans(_ type: GmarketSans, size: CGFloat = 17) -> Font {
        return .custom(type.value, size: size)
    }
}
