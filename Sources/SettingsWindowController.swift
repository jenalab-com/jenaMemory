import AppKit

// MARK: - UserDefaults Keys

private enum SettingsKey {
    static let autoOptimizeEnabled     = "autoOptimizeEnabled"
    static let autoOptimizeThresholdMB = "autoOptimizeThresholdMB"
}

// MARK: - Settings Access

enum Settings {
    static var autoOptimizeEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: SettingsKey.autoOptimizeEnabled) }
        set { UserDefaults.standard.set(newValue, forKey: SettingsKey.autoOptimizeEnabled) }
    }

    static var autoOptimizeThresholdMB: Int {
        get {
            let v = UserDefaults.standard.integer(forKey: SettingsKey.autoOptimizeThresholdMB)
            return v > 0 ? v : 1024
        }
        set { UserDefaults.standard.set(max(1, newValue), forKey: SettingsKey.autoOptimizeThresholdMB) }
    }
}

// MARK: - SettingsWindowController

final class SettingsWindowController: NSWindowController {

    static let shared = SettingsWindowController()

    // Auto-optimize section
    private let sectionLabel    = NSTextField(labelWithString: "")
    private let enableCheckbox  = NSButton(checkboxWithTitle: "", target: nil, action: nil)
    private let thresholdLabel  = NSTextField(labelWithString: "")
    private let thresholdField: NSTextField = {
        let f = NSTextField()
        f.placeholderString = "1024"
        f.alignment = .right
        return f
    }()
    private let mbLabel = NSTextField(labelWithString: "MB")

    // Language section
    private let languageSectionLabel = NSTextField(labelWithString: "")
    private let languagePopup        = NSPopUpButton()

    // Save
    private let saveBtn = NSButton(title: "", target: nil, action: nil)

    private init() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 220),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        panel.isReleasedWhenClosed = false
        super.init(window: panel)
        buildUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI Construction

    private func buildUI() {
        guard let cv = window?.contentView else { return }

        let views: [NSView] = [sectionLabel, enableCheckbox, thresholdLabel,
                               thresholdField, mbLabel, languageSectionLabel,
                               languagePopup, saveBtn]
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cv.addSubview($0)
        }

        let separator = NSBox()
        separator.boxType = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        cv.addSubview(separator)

        // Checkbox
        enableCheckbox.target = self
        enableCheckbox.action = #selector(toggleEnable)

        // Threshold field
        thresholdField.translatesAutoresizingMaskIntoConstraints = false

        // Language popup
        for lang in Language.allCases {
            languagePopup.addItem(withTitle: lang.displayName)
            languagePopup.lastItem?.representedObject = lang.rawValue
        }

        // Save button
        saveBtn.bezelStyle = .rounded
        saveBtn.keyEquivalent = "\r"
        saveBtn.target = self
        saveBtn.action = #selector(save)

        // Font
        sectionLabel.font = .boldSystemFont(ofSize: 13)
        languageSectionLabel.font = .boldSystemFont(ofSize: 13)

        NSLayoutConstraint.activate([
            // Auto-optimize section
            sectionLabel.topAnchor.constraint(equalTo: cv.topAnchor, constant: 20),
            sectionLabel.leadingAnchor.constraint(equalTo: cv.leadingAnchor, constant: 20),

            enableCheckbox.topAnchor.constraint(equalTo: sectionLabel.bottomAnchor, constant: 10),
            enableCheckbox.leadingAnchor.constraint(equalTo: cv.leadingAnchor, constant: 20),

            thresholdLabel.topAnchor.constraint(equalTo: enableCheckbox.bottomAnchor, constant: 10),
            thresholdLabel.leadingAnchor.constraint(equalTo: cv.leadingAnchor, constant: 20),

            thresholdField.centerYAnchor.constraint(equalTo: thresholdLabel.centerYAnchor),
            thresholdField.leadingAnchor.constraint(equalTo: thresholdLabel.trailingAnchor, constant: 8),
            thresholdField.widthAnchor.constraint(equalToConstant: 64),

            mbLabel.centerYAnchor.constraint(equalTo: thresholdLabel.centerYAnchor),
            mbLabel.leadingAnchor.constraint(equalTo: thresholdField.trailingAnchor, constant: 6),

            // Separator
            separator.topAnchor.constraint(equalTo: thresholdLabel.bottomAnchor, constant: 16),
            separator.leadingAnchor.constraint(equalTo: cv.leadingAnchor, constant: 20),
            separator.trailingAnchor.constraint(equalTo: cv.trailingAnchor, constant: -20),

            // Language section
            languageSectionLabel.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 14),
            languageSectionLabel.leadingAnchor.constraint(equalTo: cv.leadingAnchor, constant: 20),

            languagePopup.centerYAnchor.constraint(equalTo: languageSectionLabel.centerYAnchor),
            languagePopup.leadingAnchor.constraint(equalTo: languageSectionLabel.trailingAnchor, constant: 12),
            languagePopup.widthAnchor.constraint(equalToConstant: 140),

            // Save button
            saveBtn.topAnchor.constraint(equalTo: languageSectionLabel.bottomAnchor, constant: 20),
            saveBtn.trailingAnchor.constraint(equalTo: cv.trailingAnchor, constant: -20),
            saveBtn.bottomAnchor.constraint(equalTo: cv.bottomAnchor, constant: -20),
        ])
    }

    // MARK: - State

    private func updateLabels() {
        window?.title                    = L.settingsTitle
        sectionLabel.stringValue         = L.autoOptimizeSection
        enableCheckbox.title             = L.enable
        thresholdLabel.stringValue       = L.thresholdLabel + ":"
        languageSectionLabel.stringValue = L.language
        saveBtn.title                    = L.save
    }

    private func loadSettings() {
        updateLabels()
        enableCheckbox.state      = Settings.autoOptimizeEnabled ? .on : .off
        thresholdField.stringValue = "\(Settings.autoOptimizeThresholdMB)"
        thresholdField.isEnabled  = Settings.autoOptimizeEnabled

        let currentLang = Settings.language
        for (i, lang) in Language.allCases.enumerated() where lang.rawValue == currentLang {
            languagePopup.selectItem(at: i)
            break
        }
    }

    @objc private func toggleEnable() {
        thresholdField.isEnabled = enableCheckbox.state == .on
    }

    @objc private func save() {
        Settings.autoOptimizeEnabled     = enableCheckbox.state == .on
        Settings.autoOptimizeThresholdMB = Int(thresholdField.stringValue) ?? 1024

        let selectedIndex = languagePopup.indexOfSelectedItem
        if selectedIndex >= 0 && selectedIndex < Language.allCases.count {
            let newLang = Language.allCases[selectedIndex].rawValue
            let changed = newLang != Settings.language
            Settings.language = newLang
            if changed {
                NotificationCenter.default.post(name: .languageDidChange, object: nil)
            }
        }
        window?.close()
    }

    // MARK: - Show

    func show() {
        loadSettings()
        if window?.isVisible == false { window?.center() }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
