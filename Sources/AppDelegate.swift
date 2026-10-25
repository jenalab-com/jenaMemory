import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        LaunchAtLogin.syncAtLaunch()   // 최초 실행 시 기본 ON · 번들 이동 시 재등록
        menuBarController = MenuBarController()
    }
}
