import SwiftUI

struct MoreView: View {
    @Environment(AppStore.self) private var store
    @State private var confirmClear = false
    var body: some View {
        @Bindable var store = store
        List {
            Section(store.text("مكتبتي", "My library")) {
                NavigationLink { SavedRoutesView(favoritesOnly: true) } label: {
                    Label(store.text("المفضلة", "Favorites"), systemImage: "star")
                }
                NavigationLink { SavedRoutesView(favoritesOnly: false) } label: {
                    Label(store.text("شوهد مؤخراً", "Recently viewed"), systemImage: "clock")
                }
            }
            Section(store.text("النادي", "The club")) {
                RouteRows(routes: WebsiteCatalog.routes.filter { $0.category == .more })
            }
            Section(store.text("الإعدادات", "Settings")) {
                Picker(store.text("اللغة", "Language"), selection: $store.language) {
                    Text("العربية").tag(AppLanguage.ar)
                    Text("English").tag(AppLanguage.en)
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("languagePicker")
                Button(store.text("مسح سجل المشاهدة", "Clear viewing history"), role: .destructive) { confirmClear = true }
                    .disabled(store.recentIDs.isEmpty)
            }
            Section {
                Text(store.text("تُحفظ المفضلة وسجل المشاهدة على هذا الجهاز. تستخدم صفحات الموقع ملفات تعريف الارتباط الخاصة بها. البحث هنا يبحث في عناوين الأقسام والخدمات.", "Favorites and history stay on this device. Website pages use their own cookies. Search covers section and service titles."))
                    .font(.footnote).foregroundStyle(.secondary)
            }
        }
        .confirmationDialog(store.text("مسح سجل المشاهدة؟", "Clear viewing history?"), isPresented: $confirmClear, titleVisibility: .visible) {
            Button(store.text("مسح السجل", "Clear history"), role: .destructive) { store.clearHistory() }
            Button(store.text("إلغاء", "Cancel"), role: .cancel) {}
        }
    }
}

struct SavedRoutesView: View {
    @Environment(AppStore.self) private var store
    let favoritesOnly: Bool
    private var routes: [WebsiteRoute] {
        if favoritesOnly { return WebsiteCatalog.routes.filter { store.favorites.contains($0.id) } }
        return store.recentIDs.compactMap { id in WebsiteCatalog.routes.first { $0.id == id } }
    }
    var body: some View {
        List { RouteRows(routes: routes) }
            .navigationTitle(favoritesOnly ? store.text("المفضلة", "Favorites") : store.text("شوهد مؤخراً", "Recently viewed"))
            .overlay {
                if routes.isEmpty {
                    ContentUnavailableView(favoritesOnly ? store.text("لا توجد مفضلة بعد", "No favorites yet") : store.text("لا يوجد سجل بعد", "No history yet"), systemImage: favoritesOnly ? "star" : "clock", description: Text(store.text("افتح أحد الأقسام للبدء. استخدم النجمة لحفظه في المفضلة.", "Open a section to begin. Use the star to save a favorite.")))
                }
            }
    }
}
