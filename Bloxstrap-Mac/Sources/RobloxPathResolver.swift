import AppKit
import Foundation

public struct RobloxPathResolver {
    /// Discovers the active Roblox.app installation bundle path on macOS
    public static var robloxAppPath: String? {
        // 1. Check AppKit registered application for com.roblox.RobloxPlayer
        if let appUrl = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.roblox.RobloxPlayer"),
           FileManager.default.fileExists(atPath: appUrl.path) {
            return appUrl.path
        }
        
        // 2. User-specific Applications directory (~/Applications/Roblox.app)
        let userApp = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Applications/Roblox.app").path
        if FileManager.default.fileExists(atPath: userApp) {
            return userApp
        }
        
        // 3. System-wide Applications directory (/Applications/Roblox.app)
        let systemApp = "/Applications/Roblox.app"
        if FileManager.default.fileExists(atPath: systemApp) {
            return systemApp
        }
        
        return nil
    }
    
    public static var isRobloxInstalled: Bool {
        return robloxAppPath != nil
    }
    
    public static var soundsDirectory: String? {
        guard let app = robloxAppPath else { return nil }
        return (app as NSString).appendingPathComponent("Contents/Resources/content/sounds")
    }
    
    public static var ouchSoundPath: String? {
        guard let dir = soundsDirectory else { return nil }
        return (dir as NSString).appendingPathComponent("ouch.ogg")
    }
    
    public static var backupSoundPath: String? {
        guard let dir = soundsDirectory else { return nil }
        return (dir as NSString).appendingPathComponent("ouch.ogg.bak")
    }
    
    public static var appBundleClientSettingsDirectory: String? {
        guard let app = robloxAppPath else { return nil }
        return (app as NSString).appendingPathComponent("Contents/MacOS/ClientSettings")
    }
}
