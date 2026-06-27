import SwiftUI

/// Displays a video thumbnail loaded asynchronously.
struct VideoThumbnailView: View {
    let url: URL?
    let size: CGFloat
    
    @State private var thumbnail: UIImage?
    
    var body: some View {
        Group {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.bgElevated)
                        .frame(width: size, height: size)
                    Image(systemName: iconName)
                        .foregroundColor(.accent)
                        .font(.system(size: size * 0.45))
                }
            }
        }
        .task {
            await loadThumbnail()
        }
    }
    
    private var iconName: String {
        guard let url else { return "doc" }
        let ext = url.pathExtension.lowercased()
        if ["mov", "mp4", "avi", "mkv"].contains(ext) { return "film" }
        if ["m4a", "mp3", "wav", "aac"].contains(ext) { return "music.note" }
        return "doc"
    }
    
    private func loadThumbnail() async {
        guard let url else { return }
        let ext = url.pathExtension.lowercased()
        guard ["mov", "mp4", "avi", "mkv"].contains(ext) else { return }
        
        let img = await Task.detached {
            ThumbnailGenerator.thumbnail(for: url, maxSize: size * 2)
        }.value
        await MainActor.run { thumbnail = img }
    }
}
