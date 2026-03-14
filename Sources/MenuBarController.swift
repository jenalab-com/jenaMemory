import AppKit

class MenuBarController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var timer: Timer?
    private var lastAutoOptimizeDate = Date.distantPast

    // 동적으로 갱신되는 메뉴 아이템들
    private let totalItem      = makeStatItem()
    private let usedItem       = makeStatItem()
    private let cachedItem     = makeStatItem()
    private let freeItem       = makeStatItem()
    private let wiredItem      = makeStatItem()
    private let activeItem     = makeStatItem()
    private let inactiveItem   = makeStatItem()
    private let compressedItem = makeStatItem()

    // 언어 변경 시 타이틀을 갱신할 정적 메뉴 아이템들
    private let optimizeMenuItem  = NSMenuItem()
    private let settingsMenuItem  = NSMenuItem()
    private let aboutMenuItem     = NSMenuItem()
    private let detailHeaderItem  = NSMenuItem()
    private let quitMenuItem      = NSMenuItem()

    init() {
        buildMenu()
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            self?.refresh()
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onLanguageChanged),
            name: .languageDidChange,
            object: nil
        )
    }

    // MARK: - Menu

    private func buildMenu() {
        let menu = NSMenu()

        // 상단 액션
        optimizeMenuItem.action       = #selector(optimize)
        optimizeMenuItem.target       = self
        optimizeMenuItem.keyEquivalent = "p"
        menu.addItem(optimizeMenuItem)

        settingsMenuItem.action       = #selector(openSettings)
        settingsMenuItem.target       = self
        settingsMenuItem.keyEquivalent = ","
        menu.addItem(settingsMenuItem)

        aboutMenuItem.action       = #selector(openAbout)
        aboutMenuItem.target       = self
        aboutMenuItem.keyEquivalent = "i"
        menu.addItem(aboutMenuItem)

        menu.addItem(.separator())

        // 앱 이름 (브랜드명 — 다국어 불필요)
        menu.addItem(withTitle: "jenaMemory", action: nil, keyEquivalent: "").isEnabled = false
        menu.addItem(.separator())

        for item in [totalItem, usedItem, cachedItem, freeItem] { menu.addItem(item) }
        menu.addItem(.separator())

        detailHeaderItem.isEnabled = false
        menu.addItem(detailHeaderItem)
        for item in [wiredItem, activeItem, inactiveItem, compressedItem] { menu.addItem(item) }
        menu.addItem(.separator())

        quitMenuItem.action       = #selector(NSApplication.terminate(_:))
        quitMenuItem.keyEquivalent = "q"
        menu.addItem(quitMenuItem)

        statusItem.menu = menu

        if let button = statusItem.button {
            button.imageScaling = .scaleProportionallyDown
            button.imagePosition = .imageLeft
            button.font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        }

        updateStaticTitles()
    }

    /// 정적 메뉴 타이틀을 현재 언어로 갱신
    private func updateStaticTitles() {
        optimizeMenuItem.title = L.optimizeMemory
        settingsMenuItem.title = L.settingsMenu
        aboutMenuItem.title    = L.aboutMenu
        detailHeaderItem.title = L.details
        quitMenuItem.title     = L.quit
    }

    @objc private func onLanguageChanged() {
        updateStaticTitles()
        refresh() // 동적 stats도 즉시 갱신
    }

    // MARK: - Update

    private func refresh() {
        guard let m = MemoryMonitor.fetch() else { return }
        DispatchQueue.main.async { [weak self] in
            self?.updateUI(m)
            self?.checkAutoOptimize(m)
        }
    }

    private func checkAutoOptimize(_ m: MemoryInfo) {
        guard Settings.autoOptimizeEnabled else { return }
        let thresholdBytes = UInt64(Settings.autoOptimizeThresholdMB) * 1_048_576
        guard m.free < thresholdBytes else { return }
        // 60초 쿨다운 — 연속 트리거 방지
        guard Date().timeIntervalSince(lastAutoOptimizeDate) > 60 else { return }
        lastAutoOptimizeDate = Date()
        optimize()
    }

    private func updateUI(_ m: MemoryInfo) {
        let usedPct = m.usedPercent

        // 상태바 아이콘 + 텍스트
        statusItem.button?.image = memoryIcon(usedPercent: usedPct)
        statusItem.button?.title = " \(m.freePercent)% \(L.freeWord)"

        // 메뉴 아이템 (다국어 레이블)
        // total = used + cached + free 로 일치
        totalItem.title      = "  \(L.total)       \(MemoryInfo.format(m.total))"
        usedItem.title       = "  \(L.used)       \(MemoryInfo.format(m.used))  (\(usedPct)%)"
        cachedItem.title     = "  \(L.cached)      \(MemoryInfo.format(m.cached))"
        freeItem.title       = "  \(L.free)       \(MemoryInfo.format(m.available))"
        wiredItem.title      = "    Wired       \(MemoryInfo.format(m.wired))"
        activeItem.title     = "    Active      \(MemoryInfo.format(m.active))"
        inactiveItem.title   = "    Inactive    \(MemoryInfo.format(m.inactive))"
        compressedItem.title = "    Compressed  \(MemoryInfo.format(m.compressed))"
    }

    // MARK: - Icon

    /// RAM 스틱 모양 게이지 아이콘 — isTemplate=true 로 다크/라이트 모드 자동 대응
    private func memoryIcon(usedPercent: Int) -> NSImage {
        let size = NSSize(width: 16, height: 18)
        let image = NSImage(size: size, flipped: false) { _ in
            NSColor.black.set()

            // 하단 핀 4개
            let pinH: CGFloat = 3
            for x: CGFloat in [3.5, 6.5, 9.5, 12.5] {
                NSBezierPath(rect: NSRect(x: x, y: 0, width: 1, height: pinH)).fill()
            }

            // 본체 외곽선
            let body = NSRect(x: 1.5, y: pinH, width: 13, height: 14)
            let outline = NSBezierPath(roundedRect: body, xRadius: 1.5, yRadius: 1.5)
            outline.lineWidth = 1.5
            NSColor.black.setStroke()
            outline.stroke()

            // 게이지 채우기 (하단 → 상단, 사용률 기준)
            let maxH = body.height - 3
            let fillH = maxH * CGFloat(usedPercent) / 100
            if fillH > 0.5 {
                let fill = NSRect(x: body.minX + 2, y: body.minY + 1.5,
                                  width: body.width - 4, height: fillH)
                NSBezierPath(roundedRect: fill, xRadius: 0.5, yRadius: 0.5).fill()
            }

            return true
        }
        image.isTemplate = true
        return image
    }

    // MARK: - Settings

    @objc private func openSettings() {
        SettingsWindowController.shared.show()
    }

    // MARK: - About

    @objc private func openAbout() {
        AboutWindowController.shared.show()
    }

    // MARK: - Optimize

    /// purge 실행 — 최초 1회만 암호 요청, 이후 재사용
    @objc private func optimize() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            _ = PrivilegedExecutor.shared.runPurge()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.refresh()
            }
        }
    }
}

// MARK: - Helpers

private func makeStatItem() -> NSMenuItem {
    let item = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    item.isEnabled = false
    return item
}
