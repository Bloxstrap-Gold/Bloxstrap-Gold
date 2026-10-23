import Foundation

public class AppState {
    public static let shared = AppState()
    
    public struct AccountProfile: Codable, Identifiable {
        public var id: String
        public var username: String
        public var displayName: String
        public var userId: String
        public var avatarUrl: String
        public var tag: String // "Main", "Alt", "Farming", "Bank", "Trading"
        public var note: String
        public var addedDate: String
        
        public init(
            id: String = UUID().uuidString,
            username: String,
            displayName: String,
            userId: String = "1",
            avatarUrl: String = "",
            tag: String = "Main",
            note: String = "",
            addedDate: String = "2026-10-23"
        ) {
            self.id = id
            self.username = username
            self.displayName = displayName
            self.userId = userId
            self.avatarUrl = avatarUrl
            self.tag = tag
            self.note = note
            self.addedDate = addedDate
        }
        
        enum CodingKeys: String, CodingKey {
            case id, username, displayName, userId, avatarUrl, tag, note, addedDate
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
            self.username = try container.decodeIfPresent(String.self, forKey: .username) ?? "Player"
            self.displayName = try container.decodeIfPresent(String.self, forKey: .displayName) ?? self.username
            self.userId = try container.decodeIfPresent(String.self, forKey: .userId) ?? "1"
            self.avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl) ?? ""
            self.tag = try container.decodeIfPresent(String.self, forKey: .tag) ?? "Main"
            self.note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
            self.addedDate = try container.decodeIfPresent(String.self, forKey: .addedDate) ?? "2026-10-23"
        }
    }
    
    public struct StateData: Codable {
        public var firstRunDate: Date?
        public var hasSeenGoldGreeting: Bool = false
        public var forceTrialExpired: Bool = false
        public var isPaymentIgnored: Bool = false
        public var isBannerDismissed: Bool = false
        public var vipKey: String? = nil
        public var hasSeenWelcomeIntro: Bool = false
        public var isFastFlagsUnlocked: Bool = false
        public var multiInstanceEnabled: Bool = true
        
        // FastFlags
        public var targetFps: Int = 9999
        public var preferredLighting: String = "Future (Phase 3)"
        public var escapeMenuVersion: String = "Version 4 (2023)"
        public var hideGuisEnabled: Bool = true
        
        // Mods & Engine (Modern Upstream Bloxstrap Spec)
        public var preserveRenderingQualityDpi: Bool = true
        public var textureQuality: String = "Default"
        public var customDeathSound: Bool = true
        public var mouseCursor: String = "Default"
        public var oldAvatarBackground: Bool = false
        public var emojiFont: String = "Default"
        
        // Legacy fields preserved for backward compatibility
        public var renderingMode: String = "Direct3D 11"
        public var exclusiveFullscreen: Bool = false
        public var alternateQualitySelector: Bool = false
        public var inGameMenuVersion: String = "Version 4 (2023)"
        public var disableFullscreenOptimizations: Bool = false
        
        // Integrations
        public var activityTrackingEnabled: Bool = true
        public var showServerDetailsEnabled: Bool = true
        public var dontExitToDesktopApp: Bool = true
        public var discordActivityEnabled: Bool = true
        public var discordActivityJoinEnabled: Bool = true
        public var discordAccountOnProfile: Bool = true
        
        // Appearance
        public var theme: String = "Dark (Windows 11 Mica)"
        public var language: String = "System default"
        public var bootstrapperStyle: String = "Fluent"
        public var robloxIcon: String = "2022 (Modern Silver)"
        public var customTitle: String = "Roblox"
        
        // Behaviour & Bootstrapper Core
        public var autoUpdateChecking: Bool = true
        public var confirmLaunches: Bool = false
        public var backgroundUpdates: Bool = true
        public var forceRobloxReinstall: Bool = false
        public var telemetryEnabled: Bool = false
        
        // Bootstrapper Debug & Diagnostic Options
        public var developerMode: Bool = false
        public var robloxChannel: String = "LIVE"
        public var debugDisablePackageCleanup: Bool = false
        public var bypassConnectivityChecks: Bool = false
        public var verboseBootstrapperLogging: Bool = false
        
        // Installation
        public var createDesktopShortcuts: Bool = true
        public var createAppsShortcut: Bool = true
        public var registerUrlHandler: Bool = true
        
        // Account Manager (RAM Profiles with verified Roblox CDN avatars)
        public var accounts: [AccountProfile] = [
            AccountProfile(
                id: "1",
                username: "Roblox",
                displayName: "Primary Account",
                userId: "1",
                avatarUrl: "https://tr.rbxcdn.com/30DAY-AvatarHeadshot-310966282D3529E36976BF6B07B1DC90-Png/150/150/AvatarHeadshot/Png/noFilter",
                tag: "Main",
                note: "Primary gaming profile",
                addedDate: "2026-10-22"
            ),
            AccountProfile(
                id: "2",
                username: "BloxFarmer_99",
                displayName: "Blox Fruits Farmer",
                userId: "156",
                avatarUrl: "https://tr.rbxcdn.com/30DAY-AvatarHeadshot-635A2AA0A87D473B6136800B5B86F761-Png/150/150/AvatarHeadshot/Png/noFilter",
                tag: "Farming",
                note: "Max level 2550 • Auto-farming alt",
                addedDate: "2026-10-23"
            ),
            AccountProfile(
                id: "3",
                username: "TradeMaster_VIP",
                displayName: "Rare Item Trader",
                userId: "261",
                avatarUrl: "https://tr.rbxcdn.com/30DAY-AvatarHeadshot-3B3B81F4602EE5424673376A726F427E-Png/150/150/AvatarHeadshot/Png/noFilter",
                tag: "Trading",
                note: "Limiteds & trading hub alt",
                addedDate: "2026-10-23"
            ),
            AccountProfile(
                id: "4",
                username: "pizzaboxer",
                displayName: "Bloxstrap Dev Alt",
                userId: "6276777",
                avatarUrl: "https://tr.rbxcdn.com/30DAY-AvatarHeadshot-59378961EA8345F17879FB7148754D1B-Png/150/150/AvatarHeadshot/Png/noFilter",
                tag: "Alt",
                note: "Testing & development account",
                addedDate: "2026-10-23"
            )
        ]
        
        enum CodingKeys: String, CodingKey {
            case firstRunDate, hasSeenGoldGreeting, forceTrialExpired, isPaymentIgnored, isBannerDismissed
            case vipKey, hasSeenWelcomeIntro, isFastFlagsUnlocked, multiInstanceEnabled
            case targetFps, preferredLighting, escapeMenuVersion, hideGuisEnabled
            case preserveRenderingQualityDpi, textureQuality
            case renderingMode, exclusiveFullscreen, alternateQualitySelector, inGameMenuVersion, disableFullscreenOptimizations, customDeathSound, mouseCursor, oldAvatarBackground, emojiFont
            case activityTrackingEnabled, showServerDetailsEnabled, dontExitToDesktopApp, discordActivityEnabled, discordActivityJoinEnabled, discordAccountOnProfile
            case theme, language, bootstrapperStyle, robloxIcon, customTitle
            case autoUpdateChecking, confirmLaunches, backgroundUpdates, forceRobloxReinstall, telemetryEnabled
            case developerMode, robloxChannel, debugDisablePackageCleanup, bypassConnectivityChecks, verboseBootstrapperLogging
            case createDesktopShortcuts, createAppsShortcut, registerUrlHandler
            case accounts
        }
        
        public init() {}
        
        public init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            self.firstRunDate = try c.decodeIfPresent(Date.self, forKey: .firstRunDate)
            self.hasSeenGoldGreeting = try c.decodeIfPresent(Bool.self, forKey: .hasSeenGoldGreeting) ?? false
            self.forceTrialExpired = try c.decodeIfPresent(Bool.self, forKey: .forceTrialExpired) ?? false
            self.isPaymentIgnored = try c.decodeIfPresent(Bool.self, forKey: .isPaymentIgnored) ?? false
            self.isBannerDismissed = try c.decodeIfPresent(Bool.self, forKey: .isBannerDismissed) ?? false
            self.vipKey = try c.decodeIfPresent(String.self, forKey: .vipKey)
            self.hasSeenWelcomeIntro = try c.decodeIfPresent(Bool.self, forKey: .hasSeenWelcomeIntro) ?? false
            self.isFastFlagsUnlocked = try c.decodeIfPresent(Bool.self, forKey: .isFastFlagsUnlocked) ?? false
            self.multiInstanceEnabled = try c.decodeIfPresent(Bool.self, forKey: .multiInstanceEnabled) ?? true
            self.targetFps = try c.decodeIfPresent(Int.self, forKey: .targetFps) ?? 9999
            self.preferredLighting = try c.decodeIfPresent(String.self, forKey: .preferredLighting) ?? "Future (Phase 3)"
            self.escapeMenuVersion = try c.decodeIfPresent(String.self, forKey: .escapeMenuVersion) ?? "Version 4 (2023)"
            self.hideGuisEnabled = try c.decodeIfPresent(Bool.self, forKey: .hideGuisEnabled) ?? true
            self.preserveRenderingQualityDpi = try c.decodeIfPresent(Bool.self, forKey: .preserveRenderingQualityDpi) ?? true
            self.textureQuality = try c.decodeIfPresent(String.self, forKey: .textureQuality) ?? "Default"
            self.renderingMode = try c.decodeIfPresent(String.self, forKey: .renderingMode) ?? "Direct3D 11"
            self.exclusiveFullscreen = try c.decodeIfPresent(Bool.self, forKey: .exclusiveFullscreen) ?? false
            self.alternateQualitySelector = try c.decodeIfPresent(Bool.self, forKey: .alternateQualitySelector) ?? false
            self.inGameMenuVersion = try c.decodeIfPresent(String.self, forKey: .inGameMenuVersion) ?? "Version 4 (2023)"
            self.disableFullscreenOptimizations = try c.decodeIfPresent(Bool.self, forKey: .disableFullscreenOptimizations) ?? false
            self.customDeathSound = try c.decodeIfPresent(Bool.self, forKey: .customDeathSound) ?? true
            self.mouseCursor = try c.decodeIfPresent(String.self, forKey: .mouseCursor) ?? "Default"
            self.oldAvatarBackground = try c.decodeIfPresent(Bool.self, forKey: .oldAvatarBackground) ?? false
            self.emojiFont = try c.decodeIfPresent(String.self, forKey: .emojiFont) ?? "Default"
            self.activityTrackingEnabled = try c.decodeIfPresent(Bool.self, forKey: .activityTrackingEnabled) ?? true
            self.showServerDetailsEnabled = try c.decodeIfPresent(Bool.self, forKey: .showServerDetailsEnabled) ?? true
            self.dontExitToDesktopApp = try c.decodeIfPresent(Bool.self, forKey: .dontExitToDesktopApp) ?? true
            self.discordActivityEnabled = try c.decodeIfPresent(Bool.self, forKey: .discordActivityEnabled) ?? true
            self.discordActivityJoinEnabled = try c.decodeIfPresent(Bool.self, forKey: .discordActivityJoinEnabled) ?? true
            self.discordAccountOnProfile = try c.decodeIfPresent(Bool.self, forKey: .discordAccountOnProfile) ?? true
            self.theme = try c.decodeIfPresent(String.self, forKey: .theme) ?? "Dark (Windows 11 Mica)"
            self.language = try c.decodeIfPresent(String.self, forKey: .language) ?? "System default"
            self.bootstrapperStyle = try c.decodeIfPresent(String.self, forKey: .bootstrapperStyle) ?? "Fluent"
            self.robloxIcon = try c.decodeIfPresent(String.self, forKey: .robloxIcon) ?? "2022 (Modern Silver)"
            self.customTitle = try c.decodeIfPresent(String.self, forKey: .customTitle) ?? "Roblox"
            self.autoUpdateChecking = try c.decodeIfPresent(Bool.self, forKey: .autoUpdateChecking) ?? true
            self.confirmLaunches = try c.decodeIfPresent(Bool.self, forKey: .confirmLaunches) ?? false
            self.backgroundUpdates = try c.decodeIfPresent(Bool.self, forKey: .backgroundUpdates) ?? true
            self.forceRobloxReinstall = try c.decodeIfPresent(Bool.self, forKey: .forceRobloxReinstall) ?? false
            self.telemetryEnabled = try c.decodeIfPresent(Bool.self, forKey: .telemetryEnabled) ?? false
            self.developerMode = try c.decodeIfPresent(Bool.self, forKey: .developerMode) ?? false
            self.robloxChannel = try c.decodeIfPresent(String.self, forKey: .robloxChannel) ?? "LIVE"
            self.debugDisablePackageCleanup = try c.decodeIfPresent(Bool.self, forKey: .debugDisablePackageCleanup) ?? false
            self.bypassConnectivityChecks = try c.decodeIfPresent(Bool.self, forKey: .bypassConnectivityChecks) ?? false
            self.verboseBootstrapperLogging = try c.decodeIfPresent(Bool.self, forKey: .verboseBootstrapperLogging) ?? false
            self.createDesktopShortcuts = try c.decodeIfPresent(Bool.self, forKey: .createDesktopShortcuts) ?? true
            self.createAppsShortcut = try c.decodeIfPresent(Bool.self, forKey: .createAppsShortcut) ?? true
            self.registerUrlHandler = try c.decodeIfPresent(Bool.self, forKey: .registerUrlHandler) ?? true
            
            let decodedAccounts = try c.decodeIfPresent([AccountProfile].self, forKey: .accounts) ?? []
            if decodedAccounts.isEmpty {
                self.accounts = [
                    AccountProfile(
                        id: "1",
                        username: "Roblox",
                        displayName: "Primary Account",
                        userId: "1",
                        avatarUrl: "https://tr.rbxcdn.com/30DAY-AvatarHeadshot-310966282D3529E36976BF6B07B1DC90-Png/150/150/AvatarHeadshot/Png/noFilter",
                        tag: "Main",
                        note: "Primary gaming profile",
                        addedDate: "2026-10-22"
                    ),
                    AccountProfile(
                        id: "2",
                        username: "BloxFarmer_99",
                        displayName: "Blox Fruits Farmer",
                        userId: "156",
                        avatarUrl: "https://tr.rbxcdn.com/30DAY-AvatarHeadshot-635A2AA0A87D473B6136800B5B86F761-Png/150/150/AvatarHeadshot/Png/noFilter",
                        tag: "Farming",
                        note: "Max level 2550 • Auto-farming alt",
                        addedDate: "2026-10-23"
                    ),
                    AccountProfile(
                        id: "3",
                        username: "TradeMaster_VIP",
                        displayName: "Rare Item Trader",
                        userId: "261",
                        avatarUrl: "https://tr.rbxcdn.com/30DAY-AvatarHeadshot-3B3B81F4602EE5424673376A726F427E-Png/150/150/AvatarHeadshot/Png/noFilter",
                        tag: "Trading",
                        note: "Limiteds & trading hub alt",
                        addedDate: "2026-10-23"
                    ),
                    AccountProfile(
                        id: "4",
                        username: "pizzaboxer",
                        displayName: "Bloxstrap Dev Alt",
                        userId: "6276777",
                        avatarUrl: "https://tr.rbxcdn.com/30DAY-AvatarHeadshot-59378961EA8345F17879FB7148754D1B-Png/150/150/AvatarHeadshot/Png/noFilter",
                        tag: "Alt",
                        note: "Testing & development account",
                        addedDate: "2026-10-23"
                    )
                ]
            } else {
                self.accounts = decodedAccounts
            }
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
    
    // MARK: - Account Management (RAM)
    
    public func addAccount(username: String, displayName: String, userId: String, avatarUrl: String = "", tag: String, note: String) {
        let cleanUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? cleanUsername : displayName
        let cleanUserId = userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "1" : userId
        let cleanTag = tag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Alt" : tag
        
        let newAcc = AccountProfile(
            id: UUID().uuidString,
            username: cleanUsername,
            displayName: cleanDisplayName,
            userId: cleanUserId,
            avatarUrl: avatarUrl,
            tag: cleanTag,
            note: note,
            addedDate: "2026-10-23"
        )
        data.accounts.append(newAcc)
        save()
    }
    
    public func editAccount(id: String, username: String, displayName: String, userId: String, avatarUrl: String = "", tag: String, note: String) {
        if let idx = data.accounts.firstIndex(where: { $0.id == id }) {
            data.accounts[idx].username = username.trimmingCharacters(in: .whitespacesAndNewlines)
            data.accounts[idx].displayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? data.accounts[idx].username : displayName
            data.accounts[idx].userId = userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "1" : userId
            if !avatarUrl.isEmpty {
                data.accounts[idx].avatarUrl = avatarUrl
            }
            data.accounts[idx].tag = tag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Alt" : tag
            data.accounts[idx].note = note
            save()
        }
    }
    
    public func deleteAccount(id: String) {
        data.accounts.removeAll(where: { $0.id == id })
        save()
    }
    
    public func resetSampleAccounts() {
        data.accounts = [
            AccountProfile(
                id: "1",
                username: "Roblox",
                displayName: "Primary Account",
                userId: "1",
                avatarUrl: "https://tr.rbxcdn.com/30DAY-AvatarHeadshot-310966282D3529E36976BF6B07B1DC90-Png/150/150/AvatarHeadshot/Png/noFilter",
                tag: "Main",
                note: "Primary gaming profile",
                addedDate: "2026-10-22"
            ),
            AccountProfile(
                id: "2",
                username: "BloxFarmer_99",
                displayName: "Blox Fruits Farmer",
                userId: "156",
                avatarUrl: "https://tr.rbxcdn.com/30DAY-AvatarHeadshot-635A2AA0A87D473B6136800B5B86F761-Png/150/150/AvatarHeadshot/Png/noFilter",
                tag: "Farming",
                note: "Max level 2550 • Auto-farming alt",
                addedDate: "2026-10-23"
            ),
            AccountProfile(
                id: "3",
                username: "TradeMaster_VIP",
                displayName: "Rare Item Trader",
                userId: "261",
                avatarUrl: "https://tr.rbxcdn.com/30DAY-AvatarHeadshot-3B3B81F4602EE5424673376A726F427E-Png/150/150/AvatarHeadshot/Png/noFilter",
                tag: "Trading",
                note: "Limiteds & trading hub alt",
                addedDate: "2026-10-23"
            ),
            AccountProfile(
                id: "4",
                username: "pizzaboxer",
                displayName: "Bloxstrap Dev Alt",
                userId: "6276777",
                avatarUrl: "https://tr.rbxcdn.com/30DAY-AvatarHeadshot-59378961EA8345F17879FB7148754D1B-Png/150/150/AvatarHeadshot/Png/noFilter",
                tag: "Alt",
                note: "Testing & development account",
                addedDate: "2026-10-23"
            )
        ]
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
