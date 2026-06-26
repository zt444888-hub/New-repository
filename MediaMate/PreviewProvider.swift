import SwiftUI

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView(navigationPath: .constant(NavigationPath()))
                .environmentObject(AppState())
                .preferredColorScheme(.dark)
        }
        .previewDevice("iPhone 15")
    }
}

struct ConvertSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ConvertSettingsView(navigationPath: .constant(NavigationPath()))
                .environmentObject(AppState())
                .preferredColorScheme(.dark)
        }
        .previewDevice("iPhone 15")
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView(navigationPath: .constant(NavigationPath()))
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 15")
    }
}

struct CompleteView_Previews: PreviewProvider {
    static var previews: some View {
        CompleteView(navigationPath: .constant(NavigationPath()))
            .environmentObject(AppState())
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 15")
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HistoryView()
                .environmentObject(AppState())
                .preferredColorScheme(.dark)
        }
        .previewDevice("iPhone 15")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
                .preferredColorScheme(.dark)
        }
        .previewDevice("iPhone 15")
    }
}