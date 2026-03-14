import Foundation

// MARK: - Language

enum Language: String, CaseIterable {
    case ko, en, zh, ja, es, de, fr, ru, hi

    var displayName: String {
        switch self {
        case .ko: return "한국어"
        case .en: return "English"
        case .zh: return "中文"
        case .ja: return "日本語"
        case .es: return "Español"
        case .de: return "Deutsch"
        case .fr: return "Français"
        case .ru: return "Русский"
        case .hi: return "हिन्दी"
        }
    }
}

extension Settings {
    static var language: String {
        get { UserDefaults.standard.string(forKey: "language") ?? "ko" }
        set { UserDefaults.standard.set(newValue, forKey: "language") }
    }
}

extension Notification.Name {
    static let languageDidChange = Notification.Name("MemoryRescue.languageDidChange")
}

// MARK: - Strings

enum L {
    static var current: Language { Language(rawValue: Settings.language) ?? .ko }

    // MARK: Menu bar

    static var freeWord: String {
        switch current {
        case .ko: return "여유"
        case .en: return "free"
        case .zh: return "可用"
        case .ja: return "空き"
        case .es: return "libre"
        case .de: return "frei"
        case .fr: return "libre"
        case .ru: return "своб."
        case .hi: return "मुक्त"
        }
    }

    // MARK: Menu items

    static var optimizeMemory: String {
        switch current {
        case .ko: return "메모리 최적화…"
        case .en: return "Optimize Memory…"
        case .zh: return "优化内存…"
        case .ja: return "メモリを最適化…"
        case .es: return "Optimizar memoria…"
        case .de: return "Speicher optimieren…"
        case .fr: return "Optimiser la mémoire…"
        case .ru: return "Оптимизировать память…"
        case .hi: return "मेमोरी ऑप्टिमाइज़ करें…"
        }
    }

    static var settingsMenu: String {
        switch current {
        case .ko: return "설정…"
        case .en: return "Settings…"
        case .zh: return "设置…"
        case .ja: return "設定…"
        case .es: return "Configuración…"
        case .de: return "Einstellungen…"
        case .fr: return "Paramètres…"
        case .ru: return "Настройки…"
        case .hi: return "सेटिंग्स…"
        }
    }

    static var total: String {
        switch current {
        case .ko: return "전체"
        case .en: return "Total"
        case .zh: return "总计"
        case .ja: return "合計"
        case .es: return "Total"
        case .de: return "Gesamt"
        case .fr: return "Total"
        case .ru: return "Всего"
        case .hi: return "कुल"
        }
    }

    static var used: String {
        switch current {
        case .ko: return "사용 중"
        case .en: return "Used"
        case .zh: return "已用"
        case .ja: return "使用中"
        case .es: return "Usado"
        case .de: return "Belegt"
        case .fr: return "Utilisé"
        case .ru: return "Занято"
        case .hi: return "उपयोग में"
        }
    }

    static var free: String {
        switch current {
        case .ko: return "여유"
        case .en: return "Free"
        case .zh: return "可用"
        case .ja: return "空き"
        case .es: return "Libre"
        case .de: return "Frei"
        case .fr: return "Libre"
        case .ru: return "Свободно"
        case .hi: return "उपलब्ध"
        }
    }

    static var cached: String {
        switch current {
        case .ko: return "캐시"
        case .en: return "Cached"
        case .zh: return "缓存"
        case .ja: return "キャッシュ"
        case .es: return "Caché"
        case .de: return "Cache"
        case .fr: return "Cache"
        case .ru: return "Кэш"
        case .hi: return "कैश"
        }
    }

    static var details: String {
        switch current {
        case .ko: return "상세"
        case .en: return "Details"
        case .zh: return "详情"
        case .ja: return "詳細"
        case .es: return "Detalles"
        case .de: return "Details"
        case .fr: return "Détails"
        case .ru: return "Подробно"
        case .hi: return "विवरण"
        }
    }

    static var quit: String {
        switch current {
        case .ko: return "종료"
        case .en: return "Quit"
        case .zh: return "退出"
        case .ja: return "終了"
        case .es: return "Salir"
        case .de: return "Beenden"
        case .fr: return "Quitter"
        case .ru: return "Выход"
        case .hi: return "बाहर निकलें"
        }
    }

    // MARK: Settings window

    static var settingsTitle: String {
        switch current {
        case .ko: return "jenaMemory 설정"
        case .en: return "jenaMemory Settings"
        case .zh: return "jenaMemory 设置"
        case .ja: return "jenaMemory 設定"
        case .es: return "Configuración de jenaMemory"
        case .de: return "jenaMemory Einstellungen"
        case .fr: return "Paramètres de jenaMemory"
        case .ru: return "Настройки jenaMemory"
        case .hi: return "jenaMemory सेटिंग्स"
        }
    }

    static var autoOptimizeSection: String {
        switch current {
        case .ko: return "자동 메모리 최적화"
        case .en: return "Auto Memory Optimization"
        case .zh: return "自动内存优化"
        case .ja: return "自動メモリ最適化"
        case .es: return "Optimización automática de memoria"
        case .de: return "Automatische Speicheroptimierung"
        case .fr: return "Optimisation automatique de la mémoire"
        case .ru: return "Автоматическая оптимизация памяти"
        case .hi: return "स्वचालित मेमोरी अनुकूलन"
        }
    }

    static var enable: String {
        switch current {
        case .ko: return "활성화"
        case .en: return "Enable"
        case .zh: return "启用"
        case .ja: return "有効にする"
        case .es: return "Activar"
        case .de: return "Aktivieren"
        case .fr: return "Activer"
        case .ru: return "Включить"
        case .hi: return "सक्षम करें"
        }
    }

    static var thresholdLabel: String {
        switch current {
        case .ko: return "여유 임계값"
        case .en: return "Free threshold"
        case .zh: return "可用阈值"
        case .ja: return "空きしきい値"
        case .es: return "Umbral libre"
        case .de: return "Freigrenze"
        case .fr: return "Seuil libre"
        case .ru: return "Порог своб."
        case .hi: return "मुक्त सीमा"
        }
    }

    static var save: String {
        switch current {
        case .ko: return "저장"
        case .en: return "Save"
        case .zh: return "保存"
        case .ja: return "保存"
        case .es: return "Guardar"
        case .de: return "Speichern"
        case .fr: return "Enregistrer"
        case .ru: return "Сохранить"
        case .hi: return "सहेजें"
        }
    }

    static var language: String {
        switch current {
        case .ko: return "언어"
        case .en: return "Language"
        case .zh: return "语言"
        case .ja: return "言語"
        case .es: return "Idioma"
        case .de: return "Sprache"
        case .fr: return "Langue"
        case .ru: return "Язык"
        case .hi: return "भाषा"
        }
    }

    // MARK: About window

    static var aboutMenu: String {
        switch current {
        case .ko: return "정보…"
        case .en: return "About…"
        case .zh: return "关于…"
        case .ja: return "情報…"
        case .es: return "Acerca de…"
        case .de: return "Info…"
        case .fr: return "À propos…"
        case .ru: return "О программе…"
        case .hi: return "जानकारी…"
        }
    }

    static var aboutTitle: String {
        switch current {
        case .ko: return "jenaMemory 정보"
        case .en: return "About jenaMemory"
        case .zh: return "关于 jenaMemory"
        case .ja: return "jenaMemory について"
        case .es: return "Acerca de jenaMemory"
        case .de: return "Über jenaMemory"
        case .fr: return "À propos de jenaMemory"
        case .ru: return "О jenaMemory"
        case .hi: return "jenaMemory के बारे में"
        }
    }

    static var versionLabel: String {
        switch current {
        case .ko: return "버전"
        case .en: return "Version"
        case .zh: return "版本"
        case .ja: return "バージョン"
        case .es: return "Versión"
        case .de: return "Version"
        case .fr: return "Version"
        case .ru: return "Версия"
        case .hi: return "संस्करण"
        }
    }

    static var updatedLabel: String {
        switch current {
        case .ko: return "업데이트"
        case .en: return "Updated"
        case .zh: return "更新日期"
        case .ja: return "更新日"
        case .es: return "Actualizado"
        case .de: return "Aktualisiert"
        case .fr: return "Mis à jour"
        case .ru: return "Обновлено"
        case .hi: return "अपडेट"
        }
    }
}
