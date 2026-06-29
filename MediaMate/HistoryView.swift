import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""

    var body: some View {
        List {
            if appState.recentItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock")
                        .font(.system(size: 48))
                        .foregroundColor(.textTertiary)
                    Text("No conversion history")
                        .font(.system(size: 16))
                        .foregroundColor(.textSecondary)
                    Text("Your conversion history will appear here")
                        .font(.system(size: 14))
                        .foregroundColor(.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
                .listRowBackground(Color.bgPrimary)
            } else {
                let filteredItems = searchText.isEmpty
                    ? appState.recentItems
                    : appState.recentItems.filter {
                        $0.fileName.localizedCaseInsensitiveContains(searchText) ||
                        $0.fromFormat.localizedCaseInsensitiveContains(searchText) ||
                        $0.toFormat.localizedCaseInsensitiveContains(searchText)
                    }

                ForEach(filteredItems) { item in
                    HistoryListItem(item: item)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                if nil != appState.recentItems.firstIndex(where: { $0.id == item.id }) {
                                    appState.deleteConversion(item)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.bgPrimary)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.bgPrimary)
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search conversions"
        )
    }
}

#Preview {
    HistoryView()
        .environmentObject(AppState())
        .preferredColorScheme(.dark)
}
