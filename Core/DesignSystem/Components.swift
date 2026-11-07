import SwiftUI

enum BSCStyle {
    static let accent = Color(red: 0.388, green: 0.400, blue: 0.945)
    static let hero = Color(red: 0.322, green: 0.329, blue: 0.800)
    static let spacing: CGFloat = 16
}

struct RouteCard: View {
    @Environment(AppStore.self) private var store
    let route: WebsiteRoute
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: route.symbol)
                .font(.title2).foregroundStyle(BSCStyle.accent)
                .frame(width: 44, height: 44)
                .background(BSCStyle.accent.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 5) {
                Text(route.title(store.language)).font(.headline).foregroundStyle(.primary)
                Text(route.subtitle(store.language)).font(.subheadline).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            if store.favorites.contains(route.id) {
                Image(systemName: "star.fill").foregroundStyle(.orange).accessibilityLabel(store.text("محفوظ", "Saved"))
            }
        }
        .padding(.vertical, 8)
    }
}

struct RouteDestination: View {
    @Environment(AppStore.self) private var store
    let route: WebsiteRoute
    var body: some View {
        WebsiteView(route: route, language: store.language)
            .navigationTitle(route.title(store.language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        store.toggleFavorite(route)
                    } label: {
                        Image(systemName: store.favorites.contains(route.id) ? "star.fill" : "star")
                    }
                    .accessibilityLabel(store.text(store.favorites.contains(route.id) ? "إزالة من المفضلة" : "إضافة إلى المفضلة", store.favorites.contains(route.id) ? "Remove favorite" : "Add favorite"))
                }
            }
            .onAppear { store.recordVisit(route) }
    }
}

struct RouteRows: View {
    @Environment(AppStore.self) private var store
    let routes: [WebsiteRoute]
    var body: some View {
        ForEach(routes) { route in
            NavigationLink(value: route) { RouteCard(route: route) }
                .contextMenu {
                    Button { store.toggleFavorite(route) } label: {
                        Label(store.text("تبديل المفضلة", "Toggle favorite"), systemImage: "star")
                    }
                    ShareLink(item: route.url)
                }
        }
    }
}
