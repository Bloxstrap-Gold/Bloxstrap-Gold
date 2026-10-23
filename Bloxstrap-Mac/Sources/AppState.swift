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
        public var targetFps: Int = 240
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
    
    public var daysPassed: Int {
        let firstRun = data.firstRunDate ?? Date()
        let diff = Date().timeIntervalSince(firstRun)
        return Int(diff / 86400)
    }
    
    public var daysRemaining: Int {
        return max(0, 7 - daysPassed)
    }
    
    public var isExpired: Bool {
        // If payment was ignored, user has bypassed payment permanently!
        if data.isPaymentIgnored {
            return false
        }
        return data.forceTrialExpired || daysRemaining == 0
    }
    
    public func verifyAndApplyKey(_ key: String) -> Bool {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if trimmed.hasPrefix("GOLD-") && trimmed.count >= 6 {
            data.vipKey = trimmed
            data.isFastFlagsUnlocked = true
            save()
            return true
        }
        return false
    }
    
    public func setPaymentIgnored(_ ignored: Bool) {
        data.isPaymentIgnored = ignored
        if ignored {
            data.forceTrialExpired = false
        }
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
        data.isPaymentIgnored = false
        data.isBannerDismissed = false
        data.firstRunDate = Date()
        save()
    }
}
