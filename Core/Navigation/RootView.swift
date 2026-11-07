import SwiftUI

enum AppSection: String, CaseIterable, Identifiable {
    case home, study, services, activities, more
    var id: String { rawValue }
    var symbol: String {
        switch self { case .home: "house"; case .study: "books.vertical"; case .services: "square.grid.2x2"; case .activities: "calendar"; case .more: "ellipsis.circle" }
    }
    func title(_ language: AppLanguage) -> String {
        let ar = ["الرئيسية", "الدراسة", "الخدمات", "الأنشطة", "المزيد"]
        let en = ["Home", "Study", "Services", "Activities", "More"]
        return (language == .ar ? ar : en)[Self.allCases.firstIndex(of: self)!]
    }
}

struct RootView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var selection: AppSection? = .home
    var body: some View {
        if sizeClass == .regular {
            NavigationSplitView {
                List(AppSection.allCases, selection: $selection) { section in
                    Label(section.title(store.language), systemImage: section.symbol).tag(section)
                }.navigationTitle("BSC KU")
            } detail: { sectionStack(selection ?? .home).id(selection) }
        } else {
            TabView {
                ForEach(AppSection.allCases) { section in
                    sectionStack(section)
                        .tabItem { Label(section.title(store.language), systemImage: section.symbol) }
                }
            }
        }
    }
    private func sectionStack(_ section: AppSection) -> some View {
        NavigationStack {
            Group {
                switch section {
                case .home: HomeView()
                case .study: CatalogView(category: .study)
                case .services: CatalogView(category: .services)
                case .activities: CatalogView(category: .activities)
                case .more: MoreView()
                }
            }
            .navigationTitle(section.title(store.language))
            .navigationDestination(for: WebsiteRoute.self) { RouteDestination(route: $0) }
        }
    }
}
