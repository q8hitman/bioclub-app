import SwiftUI

struct CatalogView: View {
    @Environment(AppStore.self) private var store
    let category: RouteCategory
    @State private var query = ""
    private var routes: [WebsiteRoute] { store.matching(WebsiteCatalog.routes.filter { $0.category == category }, query: query) }
    var body: some View {
        List { RouteRows(routes: routes) }
            .listStyle(.insetGrouped)
            .overlay {
                if routes.isEmpty {
                    if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        ContentUnavailableView(store.text("لا توجد موارد متاحة حالياً", "No resources available yet"), systemImage: "tray")
                    } else {
                        ContentUnavailableView.search(text: query)
                    }
                }
            }
            .searchable(text: $query, prompt: store.text("ابحث في هذا القسم", "Search this section"))
    }
}
