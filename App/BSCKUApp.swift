import SwiftUI

@main
@MainActor
struct BSCKUApp: App {
    @State private var store: AppStore
    init() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--uitesting"),
           let defaults = UserDefaults(suiteName: "BSCKU.UITesting") {
            defaults.removePersistentDomain(forName: "BSCKU.UITesting")
            _store = State(initialValue: AppStore(defaults: defaults))
            return
        }
        #endif
        _store = State(initialValue: AppStore())
    }
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
