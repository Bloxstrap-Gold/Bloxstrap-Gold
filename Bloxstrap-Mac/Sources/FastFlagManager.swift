import Foundation

public struct AllowedFlag: Identifiable {
    public var id: String { key }
    public let key: String
    public let name: String
    public let description: String
    public let defaultValue: Any
    public let isAllowed: Bool
    public let category: String
}

public class FastFlagManager {
    public static let shared = FastFlagManager()
    
    // Official Roblox Allowlist & Blocked Registry (September 2025 Spec)
    public let registry: [AllowedFlag] = [
        // --- ALLOWLISTED FLAGS ---
        AllowedFlag(
            key: "DFIntTaskSchedulerTargetFps",
            name: "Target Framerate Cap",
            description: "Controls engine framerate limit (60, 144, 240, or 9999 for uncapped).",
            defaultValue: 240,
            isAllowed: true,
            category: "Performance"
        ),
        AllowedFlag(
            key: "DFFlagDisableDPIScale",
            name: "Disable Retina DPI Downscaling",
            description: "Forces 1:1 pixel rendering on Retina Mac displays for ultra-crisp visuals.",
            defaultValue: true,
            isAllowed: true,
            category: "Rendering"
        ),
        AllowedFlag(
            key: "FIntDebugForceMSAASamples",
            name: "Force MSAA Anti-Aliasing",
            description: "Multisample anti-aliasing level: 1 (Off), 2 (2x MSAA), 4 (4x MSAA).",
            defaultValue: 4,
            isAllowed: true,
            category: "Anti-Aliasing"
        ),
        AllowedFlag(
            key: "DFFlagTextureQualityOverrideEnabled",
            name: "Enable Texture Quality Override",
            description: "Enables manual override to bypass dynamic texture downsampling.",
            defaultValue: true,
            isAllowed: true,
            category: "Textures"
        ),
        AllowedFlag(
            key: "DFIntTextureQualityOverride",
            name: "Texture Quality Level",
            description: "Texture resolution levels: 0 (potato), 1 (medium), 2 (high), 3 (ultra).",
            defaultValue: 3,
            isAllowed: true,
            category: "Textures"
        ),
        AllowedFlag(
            key: "FFlagHandleAltEnterFullscreenManually",
            name: "Alt+Enter Fullscreen Handling",
            description: "Enables manual exclusive fullscreen toggle on Alt+Enter keypress.",
            defaultValue: true,
            isAllowed: true,
            category: "Input"
        ),
        AllowedFlag(
            key: "FFlagDebugDisplayFPS",
            name: "Engine HUD FPS Display",
            description: "Displays authentic native engine frames-per-second overlay.",
            defaultValue: true,
            isAllowed: true,
            category: "Telemetry"
        ),
        AllowedFlag(
            key: "FFlagDebugGraphicsPreferD3D11",
            name: "Prefer Direct3D 11",
            description: "Direct3D 11 rendering pipeline preference (Windows/Wine compatibility).",
            defaultValue: false,
            isAllowed: true,
            category: "Backend"
        ),
        AllowedFlag(
            key: "FFlagDebugGraphicsPreferVulkan",
            name: "Prefer Vulkan / MoltenVK",
            description: "Uses Vulkan/MoltenVK translation backend on macOS for smooth pacing.",
            defaultValue: true,
            isAllowed: true,
            category: "Backend"
        ),
        AllowedFlag(
            key: "FIntFRMMaxGrassDistance",
            name: "Max Grass Rendering Distance",
            description: "Extends procedural terrain grass draw distance in studs (default: 300).",
            defaultValue: 300,
            isAllowed: true,
            category: "Graphics"
        ),
        AllowedFlag(
            key: "FFlagFixGraphicsQuality",
            name: "Lock High Quality Rendering",
            description: "Prevents dynamic resolution reduction and LOD drops during heavy combat.",
            defaultValue: true,
            isAllowed: true,
            category: "Rendering"
        ),
        AllowedFlag(
            key: "DFIntCanHideGuiGroupId",
            name: "Hide GUI Developer Group ID",
            description: "Permits hiding user interface elements for cinematic screenshots.",
            defaultValue: 34970455,
            isAllowed: true,
            category: "UI"
        ),
        
        // --- BLOCKED / IGNORED BY ROBLOX ANTI-TAMPER ---
        AllowedFlag(
            key: "FFlagSimHumanoidTimestepModel",
            name: "Sim Humanoid Timestep Model",
            description: "Client physics timestep flag. Blocked by Roblox Hyperion/anti-tamper since 2024.",
            defaultValue: false,
            isAllowed: false,
            category: "Physics (Blocked)"
        ),
        AllowedFlag(
            key: "FFlagDebugDisableTelemetry",
            name: "Disable Telemetry",
            description: "Diagnostics packet disable. Ignored by modern client bootstrapper.",
            defaultValue: true,
            isAllowed: false,
            category: "Privacy (Ignored)"
        ),
        AllowedFlag(
            key: "FFlagNewLightEngine",
            name: "New Light Engine Override",
            description: "Legacy internal lighting flag. Ignored by production engine.",
            defaultValue: false,
            isAllowed: false,
            category: "Engine (Ignored)"
        ),
        AllowedFlag(
            key: "FFlagEnableInGameMenuChrome",
            name: "In-Game Menu Chrome",
            description: "Server-authoritative UI flag. Dropped from local client settings.",
            defaultValue: true,
            isAllowed: false,
            category: "UI (Ignored)"
        )
    ]
    
    private let fileManager = FileManager.default
    
    public var clientSettingsURL: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let robloxDir = appSupport.appendingPathComponent("Roblox", isDirectory: true)
        let settingsDir = robloxDir.appendingPathComponent("ClientSettings", isDirectory: true)
        try? fileManager.createDirectory(at: settingsDir, withIntermediateDirectories: true)
        return settingsDir.appendingPathComponent("ClientAppSettings.json")
    }
    
    public func loadSettings() -> [String: Any] {
        guard let data = try? Data(contentsOf: clientSettingsURL),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return [:]
        }
        return json
    }
    
    public func saveSettings(_ settings: [String: Any]) -> Bool {
        do {
            let data = try JSONSerialization.data(withJSONObject: settings, options: [.prettyPrinted, .sortedKeys])
            try data.write(to: clientSettingsURL)
            
            // Also attempt to write inside Roblox.app bundle if accessible
            let appBundleSettingsDir = URL(fileURLWithPath: "/Applications/Roblox.app/Contents/MacOS/ClientSettings")
            if fileManager.fileExists(atPath: "/Applications/Roblox.app") {
                try? fileManager.createDirectory(at: appBundleSettingsDir, withIntermediateDirectories: true)
                let appBundleJson = appBundleSettingsDir.appendingPathComponent("ClientAppSettings.json")
                try? data.write(to: appBundleJson)
            }
            return true
        } catch {
            return false
        }
    }
    
    public func setFlag(key: String, value: Any) {
        var current = loadSettings()
        current[key] = value
        _ = saveSettings(current)
    }
    
    public func removeFlag(key: String) {
        var current = loadSettings()
        current.removeValue(forKey: key)
        _ = saveSettings(current)
    }
}
