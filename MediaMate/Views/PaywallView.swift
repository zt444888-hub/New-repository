import SwiftUI
import StoreKit

@available(iOS 15.0, *)
struct PaywallView: View {
    @StateObject private var store = StoreManager.shared
    @State private var isPurchasing = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 28).fill(Color.accent).frame(width: 100, height: 100)
                Image(systemName: "film").font(.system(size: 48)).foregroundColor(.white)
            }.padding(.bottom, 20)

            Text("MediaMate").font(.system(size: 36, weight: .bold)).foregroundColor(.textPrimary)
            Text("Video & Audio Tool").font(.system(size: 16)).foregroundColor(.textSecondary).padding(.bottom, 32)

            VStack(alignment: .leading, spacing: 14) {
                FeatureRow(icon: "arrow.triangle.2.circlepath", text: "All formats: MP4, MOV, M4A, MP3, WAV, GIF")
                FeatureRow(icon: "square.stack.3d.up", text: "Batch conversion")
                FeatureRow(icon: "square.and.arrow.up", text: "Convert from any app via Share Extension")
                FeatureRow(icon: "lock.shield", text: "100% on-device. No uploads.")
                FeatureRow(icon: "xmark.circle", text: "No ads. No tracking. Ever.")
            }.padding(.horizontal, 32).padding(.bottom, 40)

            Spacer()

            if let product = store.product {
                Button {
                    Task { await purchase() }
                } label: {
                    HStack {
                        if isPurchasing { ProgressView().tint(.white) }
                        Text("Buy Full Version – \(product.displayPrice)").font(.system(size: 18, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(Color.accent).foregroundColor(.white).cornerRadius(16)
                }.disabled(isPurchasing).padding(.horizontal, 32).padding(.bottom, 8)
            } else {
                ProgressView().padding(.bottom, 8)
            }

            Button("Restore Purchases") { Task { await store.restorePurchases() } }
                .font(.system(size: 15)).foregroundColor(.textSecondary).padding(.bottom, 4)
            Button("Maybe Later") { dismiss() }
                .font(.system(size: 15)).foregroundColor(.textTertiary).padding(.bottom, 24)
        }
        .background(Color.bgPrimary)
        .onChange(of: store.isPurchased) { _, newValue in if newValue { dismiss() } }
        .interactiveDismissDisabled()
    }

    private func purchase() async {
        isPurchasing = true; defer { isPurchasing = false }
        do { try await store.purchase() }
        catch StoreError.pending { alertMessage = "Purchase pending."; showAlert = true }
        catch { alertMessage = error.localizedDescription; showAlert = true }
    }
}

private struct FeatureRow: View {
    let icon: String; let text: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 18)).foregroundColor(.accent).frame(width: 28)
            Text(text).font(.system(size: 15)).foregroundColor(.textPrimary)
            Spacer()
        }
    }
}
