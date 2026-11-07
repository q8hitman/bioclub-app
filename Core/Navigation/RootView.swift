import SwiftUI

enum AppSection: String, CaseIterable, Identifiable {
    case home, study, services, activities, more
    var id: String { rawValue }
    var symbol: String {
        switch self { case .home: "house"; case .study: "books.vertical"; case .services: "square.grid.2x2"; case .activities: "calendar"; case .more: "ellipsis.circle" }
    }
    func title(_ language: AppLanguage) -> String {
        switch self {
        case .home: language == .ar ? "الرئيسية" : "Home"
        case .study: language == .ar ? "الدراسة" : "Study"
        case .services: language == .ar ? "الخدمات" : "Services"
        case .activities: language == .ar ? "الأنشطة" : "Activities"
        case .more: language == .ar ? "المزيد" : "More"
        }
    }
}

struct RootView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var selection: AppSection? = .home
    @State private var compactSelection: AppSection = .home
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    var body: some View {
        if sizeClass == .regular {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                List(AppSection.allCases, selection: $selection) { section in
                    Label(section.title(store.language), systemImage: section.symbol).tag(section)
                }
                .id(store.language)
                .navigationTitle("BSC KU")
            } detail: { sectionStack(selection ?? .home).id("\(selection?.rawValue ?? "home")-\(store.language.rawValue)") }
            .id(store.language)
        } else {
            TabView(selection: $compactSelection) {
                ForEach(AppSection.allCases) { section in
                    sectionStack(section)
                        .id("\(section.rawValue)-\(store.language.rawValue)")
                        .tabItem { Label(section.title(store.language), systemImage: section.symbol) }
                        .tag(section)
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
