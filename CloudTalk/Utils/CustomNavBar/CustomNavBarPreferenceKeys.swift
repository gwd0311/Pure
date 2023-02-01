//
//  CustomNavBarPreferenceKeys.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/01.
//

import Foundation
import SwiftUI

struct EquatableViewContainer: Equatable {
    
    let id = UUID().uuidString
    let view:AnyView
    
    static func == (lhs: EquatableViewContainer, rhs: EquatableViewContainer) -> Bool {
        return lhs.id == rhs.id
    }
}

struct CustomNavBarTitlePreferenceKey: PreferenceKey {
    
    static var defaultValue: String = ""
    
    static func reduce(value: inout String, nextValue: () -> String) {
        value = nextValue()
    }
    
}

struct CustomNavBarSubTitlePreferenceKey: PreferenceKey {
    
    static var defaultValue: String? = nil
    
    static func reduce(value: inout String?, nextValue: () -> String?) {
        value = nextValue()
    }
    
}

struct CustomNavBarBackButtonHiddenPreferenceKey: PreferenceKey {
    
    static var defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
    
}

struct CustomNavBarItemsLeadingPreferenceKey: PreferenceKey {
    
    static var defaultValue: EquatableViewContainer = EquatableViewContainer(view: AnyView(EmptyView()))
    
    static func reduce(value: inout EquatableViewContainer, nextValue: () -> EquatableViewContainer) {
        value = nextValue()
    }
    
}

struct CustomNavBarItemsTrailingPreferenceKey: PreferenceKey {
    
    static var defaultValue: EquatableViewContainer = EquatableViewContainer(view: AnyView(EmptyView()))
    
    static func reduce(value: inout EquatableViewContainer, nextValue: () -> EquatableViewContainer) {
        value = nextValue()
    }
    
}

extension View {
    
    func customNavigationTitle(_ title: String) -> some View {
        preference(key: CustomNavBarTitlePreferenceKey.self, value: title)
    }
    
    func customNavigationBarBackButtonHidden(_ hidden: Bool) -> some View {
        preference(key: CustomNavBarBackButtonHiddenPreferenceKey.self, value: hidden)
    }
    
    func customNavBarItems<Leading: View>(leading: Leading) -> some View {
        self
            .customNavigationBarBackButtonHidden(true)
            .preference(key: CustomNavBarItemsLeadingPreferenceKey.self, value: EquatableViewContainer(view: AnyView(leading)))
    }
    
    func customNavBarItems<Trailing: View>(trailing: Trailing) -> some View {
        preference(key: CustomNavBarItemsTrailingPreferenceKey.self, value: EquatableViewContainer(view: AnyView(trailing)))
    }
    
}

extension UINavigationController: ObservableObject, UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
