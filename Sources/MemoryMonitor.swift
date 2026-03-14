import Foundation
import Darwin.Mach

struct MemoryInfo {
    let total: UInt64
    let wired: UInt64
    let active: UInt64
    let inactive: UInt64
    let compressed: UInt64
    let free: UInt64

    /// wired + active + compressed  (Activity Monitor "Memory Used" 기준)
    var used: UInt64 { wired + active + compressed }

    /// inactive = macOS 캐시 (필요 시 즉시 회수 가능)
    var cached: UInt64 { inactive }

    /// free + inactive = 실제로 사용 가능한 메모리
    var available: UInt64 { free + inactive }

    var usedPercent: Int { Int(Double(used) / Double(total) * 100) }
    var freePercent: Int { Int(Double(available) / Double(total) * 100) }

    static func format(_ bytes: UInt64) -> String {
        let gb = Double(bytes) / 1_073_741_824
        return gb >= 1
            ? String(format: "%.1f GB", gb)
            : String(format: "%.0f MB", Double(bytes) / 1_048_576)
    }
}

enum MemoryMonitor {
    /// vm_statistics64 를 통해 실시간 메모리 현황을 가져온다
    static func fetch() -> MemoryInfo? {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size
        )

        let kr = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        guard kr == KERN_SUCCESS else { return nil }

        let page = UInt64(vm_kernel_page_size)
        return MemoryInfo(
            total:      ProcessInfo.processInfo.physicalMemory,
            wired:      UInt64(stats.wire_count) * page,
            active:     UInt64(stats.active_count) * page,
            inactive:   UInt64(stats.inactive_count) * page,
            compressed: UInt64(stats.compressor_page_count) * page,
            free:       UInt64(stats.free_count) * page
        )
    }
}
