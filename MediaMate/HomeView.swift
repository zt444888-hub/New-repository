import SwiftUI
import PhotosUI
import Photos

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @Binding var navigationPath: NavigationPath
    
    @State private var showPhotoPicker = false
    @State private var selectedPhotoItems = [PhotosPickerItem]()
    @State private var showFilePicker = false
    
    @State private var photoLibraryStatus: PHAuthorizationStatus = .notDetermined
    @State private var showBatchPicker = false
    @State private var @State private var showPermissionAlert = false
    @State private var permissionAlertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("MediaMate")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.textPrimary)
                    Text("Video & Audio Tool")
                        .font(.system(size: 15))
                        .foregroundColor(.textSecondary)
                }
                
                if appState.isTestMode {
                    VStack(spacing: 8) {
                        Text("Test Mode Active")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.green)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.15))
                            .cornerRadius(8)
                        
                        Button("Switch to Real Mode") {
                            appState.isTestMode = false
                        }
                        .font(.system(size: 12))
                        .foregroundColor(.textTertiary)
                    }
                }
                
                VStack(spacing: 12) {
                    PrimaryButton(title: "Choose from Photos", icon: "photo.on.rectangle") {
                        if appState.isTestMode {
                            selectMockFile()
                        } else {
                            requestPhotoLibraryPermission()
                        }
                    }
                    SecondaryButton(title: "Choose from Files", icon: "folder") {
                        if appState.isTestMode {
                            selectMockFile()
                        } else {
                            showFilePicker = true
                        }
                    }
                }
                
                #if DEBUG
                if !appState.isTestMode {
                Button("Enable Test Mode") {
                        Task {
                            await MainActor.run {
                                MockDataGenerator.shared.setupMockFiles()
                            }
                            appState.isTestMode = true
                            appState.isTestMode = true
                        }
                    }
                    .font(.system(size: 13))
                    .foregroundColor(.textTertiary)
                    .padding(.top, 8)
                }
                #endif
                
                if !appState.recentItems.isEmpty {
                    Text("Recent Conversions")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.textPrimary)
                    
                    ForEach(appState.recentItems.prefix(5)) { item in
                        RecentRow(item: item) {
                            navigationPath.append(Route.convert)
                        }
                    }
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "film")
                            .font(.system(size: 48))
                            .foregroundColor(.textTertiary)
                        Text("No recent conversions")
                            .font(.system(size: 16))
                            .foregroundColor(.textSecondary)
                        Text("Select a file to get started")
                            .font(.system(size: 14))
                            .foregroundColor(.textTertiary)
                    }
                    .padding(.vertical, 40)
                }
            }
            .padding(.horizontal, 20)
        }
        .background(Color.bgPrimary)
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhotoItems,
            matching: .any(of: [.videos, .audios]),
            photoLibrary: .shared()
        )
        .sheet(isPresented: $showFilePicker) {
            DocumentPickerView { url in
                handlePickedFile(url)
            }
        }
        .onChange(of: selectedPhotoItems) { items in
            if let item = items.first {
                processPhotoPickerItem(item)
            }
        }
        .alert("Permission Required", isPresented: $showPermissionAlert) {
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(permissionAlertMessage)
        }
        .sheet(isPresented: $showBatchPicker) {
            BatchPickerView { urls in
                handleBatchFiles(urls)
            }
        }
        ..onAppear {
            checkPhotoLibraryPermission()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
    
    private func checkPhotoLibraryPermission() {
        photoLibraryStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    private func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                self?.photoLibraryStatus = status
                switch status {
                case .authorized, .limited:
                    self?.showPhotoPicker = true
                case .denied, .restricted:
                    self?.permissionAlertMessage = "Please enable photo library access in Settings to select media files."
                    self?.showPermissionAlert = true
                case .notDetermined:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    private func handlePickedFile(_ url: URL) {
        let fileSize = FileUtilities.formatFileSize(url.path)
        appState.originalFileName = url.lastPathComponent
        appState.originalFileSizeText = fileSize
        appState.currentFile = url
        appState.addConversion(item: ConversionItem(
            fileName: url.lastPathComponent,
            fromFormat: url.pathExtension.uppercased(),
            toFormat: appState.selectedFormat,
            originalSize: fileSize,
            convertedSize: nil,
            status: .pending,
            date: Date()
        ))
        navigationPath.append(Route.convert)
    }
    
    private func processPhotoPickerItem(_ item: PhotosPickerItem) {
        Task {
            do {
                let result = try await item.loadTransferable(type: MediaFile.self)
                if let mediaFile = result {
                    appState.currentFile = mediaFile.url
                    appState.addConversion(item: ConversionItem(
                        fileName: mediaFile.url.lastPathComponent,
                        fromFormat: mediaFile.url.pathExtension.uppercased(),
                        toFormat: appState.selectedFormat,
                        originalSize: mediaFile.size,
                        convertedSize: nil,
                        status: .pending,
                        date: Date()
                    ))
                    navigationPath.append(Route.convert)
                }
            } catch {
                /* error logged */
            }
            
            selectedPhotoItems.removeAll()
        }
    }
    
    private func selectMockFile() {
        guard let mockFile = MockDataGenerator.shared.simulatePhotoPickerSelection() else {
            /* no mock files */
            return
        }
        
        let fileInfo = MockDataGenerator.shared.getFileInfo(mockFile)
        appState.originalFileName = fileInfo.name
        appState.originalFileSizeText = fileInfo.size
        appState.isTestMode = true
        
        appState.currentFile = mockFile
        appState.addConversion(item: ConversionItem(
            fileName: fileInfo.name,
            fromFormat: fileInfo.type,
            toFormat: appState.selectedFormat,
            originalSize: fileInfo.size,
            convertedSize: nil,
            status: .pending,
            date: Date()
        ))
        
        navigationPath.append(Route.convert)
    }
}

// MARK: - Document Picker (SwiftUI wrapper)

struct DocumentPickerView: UIViewControllerRepresentable {
    let onPick: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.movie, .audio], asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        if let popover = picker.popoverPresentationController {
            popover.sourceView = picker.view
            popover.sourceRect = sourceRect
        }
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        
        init(onPick: @escaping (URL) -> Void) {
            self.onPick = onPick
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            controller.dismiss(animated: true)
            onPick(url)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            controller.dismiss(animated: true)
        }
    }
}

struct MediaFile: Transferable {
    let url: URL
    let size: String
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { media in
            SentTransferredFile(media.url)
        } importing: { received in
            let fileSize = FileUtilities.formatFileSize(received.file.path)
            return Self(url: received.file, size: fileSize)
        }
        
        FileRepresentation(contentType: .audio) { media in
            SentTransferredFile(media.url)
        } importing: { received in
            let fileSize = FileUtilities.formatFileSize(received.file.path)
            return Self(url: received.file, size: fileSize)
        }
    }
}


