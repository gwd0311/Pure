//
//  CustomNavItems.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/01.
//

import SwiftUI

struct CustomNavigationLink<Label: View, Destination: View>: View {

    let destination: Destination
    let label: Label
    let isActive: Binding<Bool>?
    let isModalActive: Binding<Bool>?

    init(@ViewBuilder destination: () -> Destination, isActive: Binding<Bool>? = nil, @ViewBuilder label: () -> Label, isModalActive: Binding<Bool>? = nil) {
        self.destination = destination()
        self.label = label()
        self.isActive = isActive
        self.isModalActive = isModalActive
    }

    var body: some View {
        if let isActive = isActive {
            NavigationLink(
                destination: makeContainerView(),
                isActive: isActive,
                label: {
                    label
                })
        } else {
            NavigationLink {
                makeContainerView()
            } label: {
                label
            }
        }
    }
    
    @ViewBuilder private func makeContainerView() -> some View {
        if let isModalActive = isModalActive {
            CustomNavBarContainerView(content: {
                destination
            }, isModalActive: isModalActive)
            .navigationBarHidden(true)
        } else {
            CustomNavBarContainerView {
                destination
            }
            .navigationBarHidden(true)
        }
    }
}

struct CustomNavBarContainerView<Content: View>: View {

    let content: Content
    let isModalActive: Binding<Bool>?
    @State private var showBackButton: Bool = true
    @State private var title: String = ""
    @State private var leading: EquatableViewContainer = EquatableViewContainer(view: AnyView(EmptyView()))
    @State private var trailing: EquatableViewContainer = EquatableViewContainer(view: AnyView(EmptyView()))

    init(@ViewBuilder content: () -> Content, isModalActive: Binding<Bool>? = nil) {
        self.content = content()
        self.isModalActive = isModalActive
    }

    var body: some View {
        VStack(spacing: 0) {
            if let isModalActive = isModalActive {
                CustomNavBarView(showBackButton: showBackButton, title: title, leading: leading.view, trailing: trailing.view)
                    .overlay(
                            Color.black.opacity(isModalActive.wrappedValue ? 0.5 : 0).ignoresSafeArea()
                    )
            } else {
                CustomNavBarView(showBackButton: showBackButton, title: title, leading: leading.view, trailing: trailing.view)
            }
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onPreferenceChange(CustomNavBarTitlePreferenceKey.self, perform: { value in
            self.title = value
        })
        .onPreferenceChange(CustomNavBarBackButtonHiddenPreferenceKey.self, perform: { value in
            self.showBackButton = !value
        })
        .onPreferenceChange(CustomNavBarItemsLeadingPreferenceKey.self, perform: { value in
            self.leading = value
        })
        .onPreferenceChange(CustomNavBarItemsTrailingPreferenceKey.self, perform: { value in
            self.trailing = value
        })
        .contentShape(Rectangle())
    }
}

struct CustomNavigationView<Content: View>: View {

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        NavigationView {
            CustomNavBarContainerView {
                content
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
