import Foundation
import AppKit

/// 관리자 권한 실행기
///
/// 동작 순서:
/// 1. `/etc/sudoers.d/memory-rescue` 규칙 존재 → `sudo -n purge` (완전 무인, 영구)
/// 2. 규칙 없음 → AppleScript로 purge 실행 + 규칙 설치를 한 번의 암호 입력으로 처리
/// 3. 이후 모든 호출은 1번 경로 — 암호 불필요
final class PrivilegedExecutor {

    static let shared = PrivilegedExecutor()
    private let sudoersPath = "/etc/sudoers.d/jena-memory"
    private init() {}

    // MARK: - Public

    func runPurge() -> Bool {
        // 빠른 경로: 이미 설치된 규칙으로 완전 무인 실행
        if hasSudoersRule(), runSilentPurge() { return true }

        // 최초 1회: 암호 입력 → purge 실행 + 규칙 설치 (동기, 메인 스레드 필요)
        if Thread.isMainThread {
            return setupAndRun()
        } else {
            var ok = false
            DispatchQueue.main.sync { ok = self.setupAndRun() }
            return ok
        }
    }

    // MARK: - Silent (sudo -n, 영구 무인)

    private func hasSudoersRule() -> Bool {
        FileManager.default.fileExists(atPath: sudoersPath)
    }

    private func runSilentPurge() -> Bool {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
        task.arguments     = ["-n", "purge"]
        task.standardOutput = FileHandle.nullDevice
        task.standardError  = FileHandle.nullDevice
        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch { return false }
    }

    // MARK: - 최초 설치 (AppleScript — 동기, 1회만 암호 요청)

    private func setupAndRun() -> Bool {
        let username = NSUserName()
        // 임시 파일에 sudoers 규칙 기록 (root 불필요)
        let tmpPath = "/tmp/memory-rescue-\(UUID().uuidString)"
        let rule    = "\(username) ALL=(ALL) NOPASSWD: /usr/sbin/purge"
        guard (try? rule.write(toFile: tmpPath, atomically: true, encoding: .utf8)) != nil
        else { return false }

        // AppleScript 는 동기 실행 — 완료 후 defer 가 실행되므로 race condition 없음
        defer { try? FileManager.default.removeItem(atPath: tmpPath) }

        // purge 실행 + sudoers 설치를 한 번의 암호 입력으로 처리
        let cmd = "purge; cp '\(tmpPath)' \(sudoersPath); chmod 440 \(sudoersPath)"
        let src = "do shell script \"\(cmd)\" with administrator privileges"
        guard let script = NSAppleScript(source: src) else { return false }

        var error: NSDictionary?
        script.executeAndReturnError(&error)
        return error == nil
    }
}
