import Foundation

public class AppState {
    public static let shared = AppState()
    
    public struct StateData: Codable {
        public var firstRunDate: Date?
        public var hasSeenGoldGreeting: Bool = false
        public var forceTrialExpired: Bool = false
        public var isPaymentIgnored: Bool = false
        public var isBannerDismissed: Bool = false
        public var vipKey: String? = nil
        public var isFastFlagsUnlocked: Bool = false
        public var multiInstanceEnabled: Bool = true
        public var targetFps: Int = 9999
        public var preferredLighting: String = "Future (Phase 3)"
        public var escapeMenuVersion: String = "Version 4 (2023)"
        public var hideGuisEnabled: Bool = true
        public var renderingMode: String = "Direct3D 11"
        public var exclusiveFullscreen: Bool = false
        public var alternateQualitySelector: Bool = false
        public var inGameMenuVersion: String = "Version 3 (2021)"
        public var disableFullscreenOptimizations: Bool = false
        public var customDeathSound: Bool = true
        public var accounts: [AccountProfile] = [
            AccountProfile(username: "Player1", displayName: "Primary Account", addedDate: "2026-10-22")
        ]
    }
    
    public struct AccountProfile: Codable {
        public var username: String
        public var displayName: String
        public var addedDate: String
        
        public init(username: String, displayName: String, addedDate: String) {
            self.username = username
            self.displayName = displayName
            self.addedDate = addedDate
        }
    }
    
    private let fileManager = FileManager.default
    private let stateURL: URL
    public var data: StateData
    
    private init() {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let bloxstrapDir = appSupport.appendingPathComponent("BloxstrapGold", isDirectory: true)
        
        try? fileManager.createDirectory(at: bloxstrapDir, withIntermediateDirectories: true)
        self.stateURL = bloxstrapDir.appendingPathComponent("state.json")
        
        if let fileData = try? Data(contentsOf: stateURL),
           let loaded = try? JSONDecoder().decode(StateData.self, from: fileData) {
            self.data = loaded
        } else {
            self.data = StateData()
        }
        
        if self.data.firstRunDate == nil {
            self.data.firstRunDate = Date()
            save()
        }
    }
    
    public func save() {
        if let encoded = try? JSONEncoder().encode(data) {
            try? encoded.write(to: stateURL)
        }
    }
    
    // MARK: - Key Authentication & Tier Detection
    
    public var isAuthenticated: Bool {
        guard let key = data.vipKey else { return false }
        return key.uppercased().hasPrefix("GOLD-7DAY-")
    }
    
    public var currentTierName: String {
        guard let key = data.vipKey?.uppercased(), key.hasPrefix("GOLD-7DAY-") else {
            return "Unauthenticated"
        }
        if key.contains("-ULTRA-") {
            return "Gold ULTRA"
        } else if key.contains("-DELUXE-") {
            return "Gold Deluxe"
        } else if key.contains("-PLUS-") {
            return "Gold Plus"
        } else if key.contains("-BASIC-") {
            return "Gold Basic"
        } else {
            return "Gold VIP Trial"
        }
    }
    
    public var currentTierBadge: String {
        guard let key = data.vipKey?.uppercased(), key.hasPrefix("GOLD-7DAY-") else {
            return "🔒 LOCKED"
        }
        if key.contains("-ULTRA-") {
            return "👑 ULTRA VIP"
        } else if key.contains("-DELUXE-") {
            return "🥇 DELUXE"
        } else if key.contains("-PLUS-") {
            return "🥈 PLUS"
        } else if key.contains("-BASIC-") {
            return "🥉 BASIC"
        } else {
            return "🟢 VIP TRIAL"
        }
    }
    
    public var currentTierPrice: String {
        guard let key = data.vipKey?.uppercased(), key.hasPrefix("GOLD-7DAY-") else {
            return "$0.00"
        }
        if key.contains("-ULTRA-") {
            return "$199.99/mo"
        } else if key.contains("-DELUXE-") {
            return "$109.99/mo"
        } else if key.contains("-PLUS-") {
            return "$54.99/mo"
        } else if key.contains("-BASIC-") {
            return "$24.99/mo"
        } else {
            return "FREE FOREVER"
        }
    }
    
    public func detectTier(from key: String) -> String {
        let upper = key.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard upper.hasPrefix("GOLD-7DAY-") else { return "Invalid" }
        if upper.contains("-ULTRA-") { return "Gold ULTRA ($199.99/mo)" }
        if upper.contains("-DELUXE-") { return "Gold Deluxe ($109.99/mo)" }
        if upper.contains("-PLUS-") { return "Gold Plus ($54.99/mo)" }
        if upper.contains("-BASIC-") { return "Gold Basic ($24.99/mo)" }
        return "VIP Free Trial (7 Days)"
    }
    
    public func verifyAndApplyKey(_ key: String) -> Bool {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard trimmed.hasPrefix("GOLD-7DAY-") && trimmed.count >= 14 else {
            return false
        }
        data.vipKey = trimmed
        data.isFastFlagsUnlocked = true
        data.isPaymentIgnored = true
        save()
        return true
    }
    
    public func deauthenticate() {
        data.vipKey = nil
        data.isFastFlagsUnlocked = false
        data.isPaymentIgnored = false
        save()
    }
    
    public var daysPassed: Int {
        let firstRun = data.firstRunDate ?? Date()
        let diff = Date().timeIntervalSince(firstRun)
        return Int(diff / 86400)
    }
    
    public var daysRemaining: Int {
        return max(0, 7 - daysPassed)
    }
    
    public var isExpired: Bool {
        if data.isPaymentIgnored { return false }
        return data.forceTrialExpired || daysRemaining == 0
    }
    
    public func setPaymentIgnored(_ ignored: Bool) {
        data.isPaymentIgnored = ignored
        if ignored { data.forceTrialExpired = false }
        save()
    }
    
    public func setBannerDismissed(_ dismissed: Bool) {
        data.isBannerDismissed = dismissed
        save()
    }
    
    public func setForceExpired(_ expired: Bool) {
        data.forceTrialExpired = expired
        if expired {
            data.isPaymentIgnored = false
            data.isBannerDismissed = false
        }
        save()
    }
    
    public func resetTrial() {
        data.forceTrialExpired = false
        data.firstRunDate = Date()
        data.hasSeenGoldGreeting = true
        data.isPaymentIgnored = false
        data.isBannerDismissed = false
        save()
    }
}
