import UIKit
import UniformTypeIdentifiers
import Social
import MobileCoreServices
import MediaMateCore

class ShareViewController: UIViewController {

    private let engine = ConversionEngine()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let statusLabel = UILabel()
    private let stackView = UIStackView()

    private var inputURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        handleInput()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        activityIndicator.color = UIColor(red: 1, green: 107/255, blue: 53/255, alpha: 1)
        activityIndicator.hidesWhenStopped = true

        statusLabel.text = "Preparing..."
        statusLabel.font = .systemFont(ofSize: 17, weight: .medium)
        statusLabel.textColor = .white
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0

        stackView.addArrangedSubview(activityIndicator)
        stackView.addArrangedSubview(statusLabel)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),
        ])

        activityIndicator.startAnimating()
    }

    private func handleInput() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachment = extensionItem.attachments?.first else {
            statusLabel.text = "No file received"
            return
        }

        let typeIdentifiers = [
            UTType.movie.identifier,
            UTType.video.identifier,
            UTType.audio.identifier,
            UTType.mpeg4Movie.identifier,
            UTType.quickTimeMovie.identifier,
        ]

        let matchedType = typeIdentifiers.first { attachment.hasItemConformingToTypeIdentifier($0) }

        guard let type = matchedType else {
            statusLabel.text = "Unsupported file type"
            return
        }

        attachment.loadItem(forTypeIdentifier: type, options: nil) { [weak self] item, error in
            guard let self = self else { return }
            if let error = error {
                DispatchQueue.main.async { self.statusLabel.text = "Error: \(error.localizedDescription)" }
                return
            }
            if let url = item as? URL {
                self.inputURL = url
                DispatchQueue.main.async { self.showFormatPicker() }
            } else if let data = item as? Data {
                // Write to temp file
                let tempDir = FileManager.default.temporaryDirectory
                let tempURL = tempDir.appendingPathComponent("input_\(UUID().uuidString).mov")
                do {
                    try data.write(to: tempURL)
                    self.inputURL = tempURL
                    DispatchQueue.main.async { self.showFormatPicker() }
                } catch {
                    DispatchQueue.main.async { self.statusLabel.text = "Error saving file" }
                }
            }
        }
    }

    private func showFormatPicker() {
        activityIndicator.stopAnimating()

        let buttons = ["MP4", "MOV", "M4A", "MP3", "GIF"]
        let buttonStack = UIStackView()
        buttonStack.axis = .vertical
        buttonStack.spacing = 12
        buttonStack.alignment = .center

        let titleLabel = UILabel()
        titleLabel.text = "Convert to..."
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        buttonStack.addArrangedSubview(titleLabel)

        for format in buttons {
            var config = UIButton.Configuration.filled()
            config.title = format
            config.baseBackgroundColor = UIColor(red: 1, green: 107/255, blue: 53/255, alpha: 1)
            config.cornerStyle = .medium
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 40, bottom: 12, trailing: 40)

            let button = UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in
                self?.startConversion(format: format)
            })
            buttonStack.addArrangedSubview(button)
        }

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.addAction(UIAction { [weak self] _ in
            self?.extensionContext?.completeRequest(returningItems: nil)
        }, for: .touchUpInside)
        buttonStack.addArrangedSubview(cancelButton)

        stackView.addArrangedSubview(buttonStack)
        statusLabel.isHidden = true
    }

    private func startConversion(format: String) {
        guard let inputURL = inputURL else { return }
        statusLabel.isHidden = false
        statusLabel.text = "Converting..."
        activityIndicator.startAnimating()

        // Remove format picker buttons
        if stackView.arrangedSubviews.count > 2 {
            for view in stackView.arrangedSubviews.dropFirst(2) {
                view.removeFromSuperview()
            }
        }

        if format == "GIF" {
            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(UUID().uuidString).gif")
            GIFExportEngine.export(sourceURL: inputURL, outputURL: outputURL) { [weak self] result in
                DispatchQueue.main.async { self?.handleResult(result) }
            }
        } else {
            let outputURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(UUID().uuidString).\(format.lowercased())")
            engine.convertFile(at: inputURL, to: format, quality: 2, resolution: "Original") { [weak self] result in
                DispatchQueue.main.async { self?.handleResult(result) }
            }
        }
    }

    private func handleResult(_ result: Result<URL, Error>) {
        activityIndicator.stopAnimating()
        switch result {
        case .success(let outputURL):
            statusLabel.text = "Done!"
            // Provide the converted file back
            let item = NSExtensionItem()
            item.attachments = [NSItemProvider(contentsOf: outputURL)].compactMap { $0 }
            extensionContext?.completeRequest(returningItems: [item])
        case .failure(let error):
            statusLabel.text = "Failed: \(error.localizedDescription)"
            statusLabel.textColor = .red
        }
    }
}
