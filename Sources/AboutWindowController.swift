import AppKit

final class AboutWindowController: NSWindowController {

    static let shared = AboutWindowController()

    private let appIconView    = NSImageView()
    private let appNameLabel   = NSTextField(labelWithString: "jenaMemory")
    private let versionRow     = makeRow()
    private let updatedRow     = makeRow()

    private static let appVersion  = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    private static let updatedDate = "2026-03-14"

    private init() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 180),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        panel.isReleasedWhenClosed = false
        super.init(window: panel)
        buildUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI

    private func buildUI() {
        guard let cv = window?.contentView else { return }

        // 앱 아이콘
        appIconView.image = NSApp.applicationIconImage
        appIconView.imageScaling = .scaleProportionallyUpOrDown

        // 앱 이름
        appNameLabel.font = .boldSystemFont(ofSize: 18)
        appNameLabel.alignment = .center

        // 행들
        let (vLabel, vValue) = versionRow
        let (uLabel, uValue) = updatedRow

        vValue.stringValue = Self.appVersion
        uValue.stringValue = Self.updatedDate

        let views: [NSView] = [appIconView, appNameLabel, vLabel, vValue, uLabel, uValue]
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cv.addSubview($0)
        }

        NSLayoutConstraint.activate([
            appIconView.topAnchor.constraint(equalTo: cv.topAnchor, constant: 24),
            appIconView.centerXAnchor.constraint(equalTo: cv.centerXAnchor),
            appIconView.widthAnchor.constraint(equalToConstant: 48),
            appIconView.heightAnchor.constraint(equalToConstant: 48),

            appNameLabel.topAnchor.constraint(equalTo: appIconView.bottomAnchor, constant: 8),
            appNameLabel.centerXAnchor.constraint(equalTo: cv.centerXAnchor),

            vLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 16),
            vLabel.leadingAnchor.constraint(equalTo: cv.leadingAnchor, constant: 40),

            vValue.centerYAnchor.constraint(equalTo: vLabel.centerYAnchor),
            vValue.trailingAnchor.constraint(equalTo: cv.trailingAnchor, constant: -40),

            uLabel.topAnchor.constraint(equalTo: vLabel.bottomAnchor, constant: 6),
            uLabel.leadingAnchor.constraint(equalTo: cv.leadingAnchor, constant: 40),

            uValue.centerYAnchor.constraint(equalTo: uLabel.centerYAnchor),
            uValue.trailingAnchor.constraint(equalTo: cv.trailingAnchor, constant: -40),
        ])
    }

    private func updateLabels() {
        window?.title = L.aboutTitle
        let (vLabel, _) = versionRow
        let (uLabel, _) = updatedRow
        vLabel.stringValue = L.versionLabel
        uLabel.stringValue = L.updatedLabel
    }

    // MARK: - Show

    func show() {
        updateLabels()
        if window?.isVisible == false { window?.center() }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - Helpers

/// (레이블, 값) 쌍 반환
private func makeRow() -> (NSTextField, NSTextField) {
    let label = NSTextField(labelWithString: "")
    label.font = .systemFont(ofSize: 12)
    label.textColor = .secondaryLabelColor

    let value = NSTextField(labelWithString: "")
    value.font = .systemFont(ofSize: 12)
    value.alignment = .right

    return (label, value)
}
