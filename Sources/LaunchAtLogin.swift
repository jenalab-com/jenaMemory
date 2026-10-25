import Foundation
import ServiceManagement

/// 시스템 시작 시 자동 실행 (macOS 13+ `SMAppService`)
///
/// 동작 원칙:
/// - 앱 안의 체크박스와 시스템 설정 > 로그인 항목이 서로 싸우지 않게, 실제 상태는 `SMAppService.status`를 기준으로 본다.
/// - 사용자가 앱에서 고른 값은 `UserDefaults`에 남긴다 (최초 1회 기본값 ON 적용용 · 앱 이동 후 재등록 판단용).
/// - 사용자가 시스템 설정에서 직접 껐다면(.notRegistered) 그 선택을 존중하고 앱 설정값도 따라 내린다.
enum LaunchAtLogin {

    private static let prefKey       = "launchAtLogin"
    private static let configuredKey = "launchAtLoginConfigured"

    /// macOS 13 미만에서는 기능 자체를 숨긴다
    static var isSupported: Bool {
        if #available(macOS 13, *) { return true }
        return false
    }

    /// 실제 등록 상태 (시스템 기준)
    static var isEnabled: Bool {
        guard #available(macOS 13, *) else { return false }
        return SMAppService.mainApp.status == .enabled
    }

    /// 등록은 했지만 사용자가 시스템 설정에서 승인해야 하는 상태
    static var requiresApproval: Bool {
        guard #available(macOS 13, *) else { return false }
        return SMAppService.mainApp.status == .requiresApproval
    }

    /// 사용자가 앱에서 고른 값
    static var preference: Bool {
        get { UserDefaults.standard.object(forKey: prefKey) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: prefKey) }
    }

    /// 켜기/끄기 — 성공 여부 반환
    @discardableResult
    static func set(_ on: Bool) -> Bool {
        guard #available(macOS 13, *) else { return false }
        preference = on
        do {
            if on  { try SMAppService.mainApp.register() }
            else   { try SMAppService.mainApp.unregister() }
            return true
        } catch {
            NSLog("[LaunchAtLogin] \(on ? "register" : "unregister") failed: \(error)")
            return false
        }
    }

    /// 앱 시작 시 한 번 호출
    /// - 최초 실행: 기본값 ON 으로 등록
    /// - 이후 실행: 설정이 ON 이면 매번 다시 등록 — 로그인 항목의 경로가 지금 실행 중인 번들을 따라오게
    ///   (.build 에서 돌리다 /Applications 로 옮겨도 끊기지 않음). 등록은 멱등이라 비용이 거의 없다.
    /// - 사용자가 시스템 설정에서 직접 껐다면(.notRegistered) 그 선택을 존중하고 앱 설정값도 내린다.
    static func syncAtLaunch() {
        guard #available(macOS 13, *) else { return }
        let defaults = UserDefaults.standard

        if !defaults.bool(forKey: configuredKey) {
            defaults.set(true, forKey: configuredKey)
            set(true)
            return
        }

        guard preference else { return }
        switch SMAppService.mainApp.status {
        case .enabled, .notFound:
            set(true)
        case .notRegistered:
            preference = false
        default:
            break                          // .requiresApproval 등: 사용자 승인 대기
        }
    }

    /// 시스템 설정 > 일반 > 로그인 항목 열기 (승인 필요 시 안내용)
    static func openSystemSettings() {
        guard #available(macOS 13, *) else { return }
        SMAppService.openSystemSettingsLoginItems()
    }
}
