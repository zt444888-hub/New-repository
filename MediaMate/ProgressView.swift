import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var appState: AppState
    @Binding var navigationPath: NavigationPath
    @State private var simulatedProgress: Double = 0

    let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()

    let progressSteps = [
        (p: 0.05, t: ""52s""),
        (p: 0.18, t: ""42s""),
        (p: 0.35, t: ""30s""),
        (p: 0.50, t: ""22s""),
        (p: 0.68, t: ""12s""),
        (p: 0.82, t: ""7s""),
        (p: 0.94, t: ""2s""),
        (p: 1.00, t: ""Done"")
    ]

    @State private var currentStep = 0

    private var displayProgress: Double {
        appState.isTestMode ? simulatedProgress : appState.engine.progress
    }

    private var isComplete: Bool {
        appState.isTestMode ? simulatedProgress >= 1.0 : appState.engine.conversionState == .completed
    }

    private var isFailed: Bool {
        !appState.isTestMode && appState.engine.conversionState == .failed
    }

    private var etaText: String {
        if isComplete { return ""Done"" }
        if appState.isTestMode {
            if currentStep < progressSteps.count {
                return ""Estimated \(progressSteps[min(currentStep, progressSteps.count - 1)].t) remaining""
            }
            return ""Finishing...""
        }
        return ""Converting...""
    }

    var body: some View {
        VStack(spacing: 32) {
            Text(appState.originalFileName.isEmpty ? ""vacation_clip.mov"" : appState.originalFileName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.textPrimary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.bgElevated)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(isFailed ? Color.red : Color.accent)
                        .frame(width: geo.size.width * displayProgress, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: displayProgress)
                        .drawingGroup()
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 20)

            Text(isFailed ? ""Failed"" : ""\(Int(displayProgress * 100))%"")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(isFailed ? .red : .accent)

            Text(etaText)
                .font(.system(size: 14))
                .foregroundColor(.textTertiary)

            if isFailed {
                Text(appState.engine.lastError ?? "The conversion could not be completed. The file format may not be supported.")
                    .font(.system(size: 13))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Button(""Go Back"") {
                    appState.engine.conversionState = .idle
                    appState.engine.progress = 0
                    appState.engine.isConverting = false
                    navigationPath.removeLast()
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.accent)
                .padding(.vertical, 14)
                .padding(.horizontal, 40)
                .background(Color.bgCard)
                .cornerRadius(16)
            } else {
                Button(""Cancel"") {
                    handleCancel()
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.red)
                .padding(.vertical, 14)
                .padding(.horizontal, 40)
                .background(Color.bgCard)
                .cornerRadius(16)
            }
        }
        .background(Color.bgPrimary)
        .navigationTitle("""")
        .navigationBarHidden(true)
        .onReceive(timer) { _ in
            if appState.isTestMode {
                updateSimulatedProgress()
            }
        }
        .onAppear {
            if appState.isTestMode {
                simulatedProgress = 0
                currentStep = 0
            }
        }
                .onChange(of: isComplete) { done in
            if done {
                if !appState.isTestMode {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
                finishConversion()
            }
        }
        .onChange(of: isFailed) { failed in
            if failed {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }

    private func updateSimulatedProgress() {
        if currentStep < progressSteps.count {
            let target = progressSteps[currentStep].p
            if simulatedProgress < target {
                simulatedProgress += 0.003
            } else {
                currentStep += 1
            }
        }
    }

    private func finishConversion() {
        if appState.isTestMode {
            appState.conversionProgress = 1.0
            appState.convertedFile = URL(fileURLWithPath: ""/mock/converted.mp4"")
        } else {
            appState.conversionProgress = 1.0
        }

        let displayFrom = appState.currentFile?.pathExtension.uppercased() ?? ""MOV""
        let displaySize = appState.originalFileSizeText.isEmpty ? ""128.0 MB"" : appState.originalFileSizeText
        let convertedSize = appState.convertedFileSizeText.isEmpty ? ""48.3 MB"" : appState.convertedFileSizeText

        let newItem = ConversionItem(
            fileName: appState.originalFileName.isEmpty ? ""vacation_clip.mov"" : appState.originalFileName,
            fromFormat: displayFrom,
            toFormat: appState.selectedFormat,
            originalSize: displaySize,
            convertedSize: convertedSize,
            status: .completed,
            date: Date()
        )
        appState.addConversion(item: newItem)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            navigationPath.append(Route.complete)
        }
    }

    private func handleCancel() {
        appState.engine.conversionState = .idle
        appState.engine.cancel()
        appState.clearCurrentConversion()
        navigationPath.removeLast()
    }
}
