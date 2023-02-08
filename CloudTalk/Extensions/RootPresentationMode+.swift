//
//  RootPresentationMode+.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/07.
//

import SwiftUI

typealias RootPresentationMode = Bool

extension RootPresentationMode {
    
    public mutating func dismiss() {
        self.toggle()
    }
}

struct RootPresentationModeKey: EnvironmentKey {
    static let defaultValue: Binding<RootPresentationMode> = .constant(RootPresentationMode())
}

extension EnvironmentValues {
    var rootPresentationMode: Binding<RootPresentationMode> {
        get { return self[RootPresentationModeKey.self] }
        set { self[RootPresentationModeKey.self] = newValue }
    }
}
