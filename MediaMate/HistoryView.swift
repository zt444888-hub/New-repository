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
                                if let idx = appState.recentItems.firstIndex(where: { $0.id == item.id }) {
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

// MARK: - History List Item

struct HistoryListItem: View {
    let item: ConversionItem

    var iconName: String {
        switch item.fromFormat.lowercased() {
        case "mov", "mp4", "avi", "mkv": return "film"
        case "m4a", "mp3", "wav", "aac": return "music.note"
        default: return "doc"
        }
    }

    var statusColor: Color {
        switch item.status {
        case .completed: return .green
        case .failed: return .red
        case .converting: return .accent
        case .pending: return .textTertiary
        }
    }

    var statusLabel: String {
        switch item.status {
        case .completed: return "Done"
        case .failed: return "Failed"
        case .converting: return "Converting..."
        case .pending: return "Pending"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.bgElevated)
                    .frame(width: 40, height: 40)
                Image(systemName: iconName)
                    .foregroundColor(.accent)
                    .font(.system(size: 18))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.fileName)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text("\(item.fromFormat) → \(item.toFormat)")
                        .font(.system(size: 12))
                        .foregroundColor(.textTertiary)
                    if let converted = item.convertedSize {
                        Text("· \(converted)")
                            .font(.system(size: 12))
                            .foregroundColor(.textTertiary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(statusLabel)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(statusColor.opacity(0.12))
                .cornerRadius(6)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.bgCard)
        .cornerRadius(12)
    }
}

#Preview {
    HistoryView()
        .environmentObject(AppState())
        .preferredColorScheme(.dark)
}
