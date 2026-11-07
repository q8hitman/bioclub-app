import SwiftUI

struct HomeView: View {
    @Environment(AppStore.self) private var store
    @State private var query = ""
    private var recent: [WebsiteRoute] { store.recentIDs.compactMap { id in WebsiteCatalog.routes.first { $0.id == id } } }
    var body: some View {
        List {
            if query.isEmpty {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("BSC KU", systemImage: "leaf.fill").font(.headline)
                        Text(store.text("نادي العلوم البيولوجية", "Biological Sciences Club"))
                            .font(.largeTitle.bold()).fixedSize(horizontal: false, vertical: true)
                        Text(store.text("جامعة الكويت · مساحة للتعلّم والاكتشاف", "Kuwait University · Learn and discover"))
                            .font(.subheadline)
                    }
                    .foregroundStyle(.white).padding(.vertical, 20)
                    .listRowBackground(BSCStyle.accent)
                }
                Section(store.text("ابدأ من هنا", "Start here")) {
                    RouteRows(routes: Array(WebsiteCatalog.routes.filter { $0.category == .study || $0.category == .services }.prefix(4)))
                }
                if !recent.isEmpty {
                    Section(store.text("شوهد مؤخراً", "Recently viewed")) { RouteRows(routes: Array(recent.prefix(5))) }
                }
                Section(store.text("الأنشطة", "Activities")) {
                    RouteRows(routes: WebsiteCatalog.routes.filter { $0.category == .activities })
                }
            } else {
                RouteRows(routes: store.matching(WebsiteCatalog.routes, query: query))
            }
        }
        .listStyle(.insetGrouped)
        .searchable(text: $query, prompt: store.text("ابحث عن خدمة أو مورد دراسي", "Search services and study resources"))
        .overlay {
            if !query.isEmpty && store.matching(WebsiteCatalog.routes, query: query).isEmpty {
                ContentUnavailableView.search(text: query)
            }
        }
    }
}

