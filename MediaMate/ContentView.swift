import SwiftUI

enum Route: Hashable {
    case trim, convert, progress, complete, batch
}

enum Tab: String, CaseIterable {
    case home, history, files, settings
}

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var navigationPath = NavigationPath()

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $navigationPath) {
                HomeView(navigationPath: $navigationPath)
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .trim: TrimView(navigationPath: $navigationPath)
                        case .convert: ConvertSettingsView(navigationPath: $navigationPath)
                        case .progress: ProgressView(navigationPath: $navigationPath)
                        case .complete: CompleteView(navigationPath: $navigationPath)
                        case .batch: BatchQueueView(navigationPath: $navigationPath)
                        }
                    }
            }
            .tabItem { Label("Home", systemImage: "house") }
            .tag(Tab.home)

            HistoryView()
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
                .tag(Tab.history)

            ConvertedFilesView()
                .tabItem { Label("Files", systemImage: "tray.full") }
                .tag(Tab.files)

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(Tab.settings)
        }
        .tint(.accent)
        .preferredColorScheme(.dark)
    }
}
