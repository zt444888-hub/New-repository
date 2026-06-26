import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var appState: AppState
    
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
            } else {
                ForEach(appState.recentItems) { item in
                    HistoryListItem(item: item)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.bgPrimary)
                }
            }
        }
        .background(Color.bgPrimary)
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }
}