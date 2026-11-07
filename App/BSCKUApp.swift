import SwiftUI

@main
struct BSCKUApp: App {
    @State private var store = AppStore()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .environment(\.locale, Locale(identifier: store.language.rawValue))
                .environment(\.layoutDirection, store.language == .ar ? .rightToLeft : .leftToRight)
                .tint(BSCStyle.accent)
        }
    }
}

