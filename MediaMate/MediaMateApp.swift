import SwiftUI
import SwiftData

@main
struct MediaMateApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
                .modelContainer(AppState.container)
        }
    }
}
