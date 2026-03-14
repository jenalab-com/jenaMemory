import AppKit

NSApplication.shared.setActivationPolicy(.accessory) // Dock에 표시 안 함
let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
NSApplication.shared.run()
