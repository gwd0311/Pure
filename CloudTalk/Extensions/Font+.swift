//
//  Font+.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/18.
//

import Foundation
import SwiftUI

extension Font {
    
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
    
    static func cookieRun(_ type: CookieRun, size: CGFloat = 17) -> Font {
        return .custom(type.value, size: size)
    }
    
}
