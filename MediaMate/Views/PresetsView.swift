import SwiftUI

struct PresetsView: View {
    @Binding var selectedPreset: Preset?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            ForEach(Preset.Category.allCases, id: \.self) { category in
                Section {
                    ForEach(Preset.all.filter { $0.category == category }) { preset in
                        Button {
                            selectedPreset = preset; dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: preset.icon).font(.system(size: 20)).foregroundColor(.accent).frame(width: 28)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(preset.name).font(.system(size: 16, weight: .medium)).foregroundColor(.textPrimary)
                                    Text("\(preset.resolution) · \(["Low","Medium","High","Lossless"][Int(preset.quality)])").font(.system(size: 12)).foregroundColor(.textTertiary)
                                }
                                Spacer()
                                Text(preset.format).font(.system(size: 12, weight: .semibold, design: .monospaced)).foregroundColor(.accent)
                                    .padding(.horizontal, 8).padding(.vertical, 3).background(Color.accent.opacity(0.12)).cornerRadius(6)
                                if selectedPreset?.id == preset.id { Image(systemName: "checkmark").foregroundColor(.accent) }
                            }.padding(.vertical, 4)
                        }.buttonStyle(.plain).listRowBackground(Color.bgCard)
                    }
                } header: {
                    Label(categoryName(category), systemImage: categoryIcon(category))
                        .font(.system(size: 13, weight: .semibold)).foregroundColor(.textSecondary).textCase(.uppercase)
                }
            }
        }
        .scrollContentBackground(.hidden).background(Color.bgPrimary)
        .navigationTitle("Presets").navigationBarTitleDisplayMode(.inline)
    }

    private func categoryIcon(_ c: Preset.Category) -> String {
        switch c { case .social: return "person.2"; case .messaging: return "bubble.left.and.bubble.right"; case .audio: return "music.note"; case .archive: return "archivebox" }
    }
    private func categoryName(_ c: Preset.Category) -> String {
        switch c { case .social: return "Social"; case .messaging: return "Messaging"; case .audio: return "Audio"; case .archive: return "Archive" }
    }
}
